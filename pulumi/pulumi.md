# Pulumi Installation & AWS S3 Backend Configuration

A step-by-step guide to installing Pulumi on Linux and configuring it to use an AWS S3 bucket as a self-managed state backend.

---

## 1. Prerequisites: AWS Credentials

Pulumi uses your standard AWS credentials to access both the S3 state backend and the AWS resources you provision. Ensure your credentials are active:

```bash
# Configure static credentials or SSO
aws configure
# (or: aws sso login --profile <your-profile>)

# Verify access
aws sts get-caller-identity
```

If you use a named profile, export it in your shell:

```bash
export AWS_PROFILE=<your-profile>
export AWS_REGION=us-east-1
```

---

## 2. Install the Pulumi CLI

Run the official install script on Linux:

```bash
curl -fsSL https://get.pulumi.com | sh
```

Add `~/.pulumi/bin` to your `PATH` (if the installer didn't already update your shell profile) and verify:

```bash
export PATH="$HOME/.pulumi/bin:$PATH"
pulumi version
```

---

## 3. Create an S3 Bucket for Pulumi State

Create a dedicated S3 bucket with **versioning** (for state recovery) and **public access blocked**:

```bash
BUCKET_NAME="my-pulumi-state-bucket-$(aws sts get-caller-identity --query Account --output text)"
REGION="us-east-1"

# 1. Create the bucket
# Note: For regions outside us-east-1, add: --create-bucket-configuration LocationConstraint=$REGION
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION"

# 2. Enable versioning (strongly recommended for state rollbacks)
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# 3. Block all public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

---

## 4. Log Pulumi into Your S3 Backend

By default, Pulumi uses Pulumi Cloud (`app.pulumi.com`). Point it to your S3 bucket instead:

```bash
pulumi login "s3://${BUCKET_NAME}?region=${REGION}&awssdk=v2"
```

* **`awssdk=v2`** ensures Pulumi uses modern AWS SDK v2 credential resolution (necessary for AWS IAM Identity Center / SSO, `AssumeRole`, and ECS/EKS roles).
* You can also scope state to a prefix inside the bucket: `s3://${BUCKET_NAME}/pulumi-state?region=${REGION}&awssdk=v2`.
* Verify your login status with `pulumi whoami -v` (it will show `Backend URL: s3://...`).

---

## 5. Choose a Secrets Provider

Because you are not using Pulumi Cloud, Pulumi needs a way to encrypt secrets in your state file. Pick one of the two options:

### Option A: Passphrase (Simplest for personal use)

Set an environment variable before running Pulumi commands (Pulumi uses this to derive an encryption key stored alongside your stack config):

```bash
export PULUMI_CONFIG_PASSPHRASE="your-strong-passphrase"
```

### Option B: AWS KMS (Recommended for production / teams)

Use an AWS KMS key so you don't need to manage a passphrase:

```bash
# Create a KMS key and alias (once)
KEY_ID=$(aws kms create-key --description "Pulumi secrets key" --query KeyMetadata.KeyId --output text)
aws kms create-alias --alias-name alias/pulumi-secrets --target-key-id "$KEY_ID"
```

---

## 6. Initialize a Pulumi Project (Python + `uv`)

Create a new project directory and initialize Pulumi with `uv` as the Python toolchain:

```bash
mkdir my-infra && cd my-infra
```

**If using a Passphrase (Option A):**

```bash
pulumi new aws-python \
  --name my-infra \
  --stack dev \
  --runtime-options toolchain=uv
```

**If using AWS KMS (Option B):**

```bash
pulumi new aws-python \
  --name my-infra \
  --stack dev \
  --runtime-options toolchain=uv \
  --secrets-provider="awskms://alias/pulumi-secrets?region=${REGION}&awssdk=v2"
```

Your generated `Pulumi.yaml` will include the `uv` toolchain configuration and can also lock the backend URL so everyone using the repo automatically connects to the same S3 bucket:

```yaml
name: my-infra
description: AWS infrastructure managed by Pulumi
runtime:
  name: python
  options:
    toolchain: uv
backend:
  url: s3://<your-bucket-name>?region=us-east-1&awssdk=v2
```

To add extra packages to the project later, use `uv add`:

```bash
uv add pulumi-awsx
```

---

## 7. Configure and Deploy

Set your target AWS region on the stack, preview changes, and deploy:

```bash
# Set the AWS region for the stack
pulumi config set aws:region us-east-1

# Store an encrypted secret in Pulumi.dev.yaml
pulumi config set --secret dbPassword "super-secret-value"

# Preview and deploy
pulumi preview
pulumi up
```

Once `pulumi up` finishes, your stack state is stored at `s3://<your-bucket-name>/.pulumi/stacks/my-infra/dev.json`.

---

## 8. Typical Pulumi Monorepo Directory Layout

```
pulumi-monorepo/
├── package.json                 # Root workspace manifest (manages packages & dependencies)
├── tsconfig.json                # Base TypeScript configuration
├── pnpm-workspace.yaml          # Workspace definition (if using pnpm/npm/yarn workspaces)
├── components/                  # Reusable custom Component Resources (DRY infrastructure)
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── vpc/                 # Standardized multi-AZ VPC component
│       │   └── index.ts
│       └── secure-bucket/       # Encrypted S3 bucket with compliance rules
│           └── index.ts
└── stacks/                      # Independent deployment units (Lifecycles & Environments)
    ├── shared-networking/       # Foundational infrastructure stack
    │   ├── Pulumi.yaml          # Project manifest
    │   ├── Pulumi.dev.yaml      # Stack config (dev environment)
    │   ├── Pulumi.prod.yaml     # Stack config (prod environment)
    │   └── index.ts             # Instantiates components/vpc
    └── app-workloads/           # Application-tier workload stack
        ├── Pulumi.yaml
        ├── Pulumi.dev.yaml
        ├── Pulumi.prod.yaml
        └── index.ts             # Consumes outputs via StackReferences or package imports
```
