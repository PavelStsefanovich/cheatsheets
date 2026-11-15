# Pulumi Developer Crash Course (Python + `uv` + AWS)

A practical developer reference and crash course for building, configuring, and operating cloud infrastructure with Pulumi using Python, `uv`, and AWS.

---

## 1. Core Mental Model & Architecture

Pulumi uses general-purpose programming languages to declare **desired state**. Rather than executing imperative API calls yourself, your Python program registers resource goals with the Pulumi Engine, which diffs them against your state file and orchestrates creates, updates, and replacements through resource providers.

### Execution Flow

```text
Your Python Code (__main__.py)
   │  (runs in Language Host via uv)
   ▼
Pulumi Engine
   ├── Reads/writes current state ──► State Backend (S3 / Pulumi Cloud)
   ├── Computes DAG & diff (preview / up)
   └── Calls Resource Providers (e.g., pulumi-aws)
          │
          ▼
       Cloud APIs (AWS)
```

### Key Hierarchy

* **Backend / Organization**: Where stack state checkpoints are stored (e.g., an S3 bucket `s3://my-state-bucket` or Pulumi Cloud).
* **Project**: A directory containing `Pulumi.yaml`, `__main__.py`, and `pyproject.toml`. Defines the runtime, project name, and shared configuration.
* **Stack**: An isolated deployment instance of a project (e.g., `dev`, `staging`, `prod`), each with its own state file and `Pulumi.<stack>.yaml` config file.
* **Resource**: A managed cloud object (e.g., an S3 bucket or IAM role), uniquely tracked in state by a **URN** (`urn:pulumi:<stack>::<project>::<type>::<logical-name>`).

---

## 2. Project Anatomy (Python + `uv`)

```text
my-infra/
├── Pulumi.yaml          # Project metadata, runtime (toolchain: uv), optional backend URL
├── Pulumi.dev.yaml      # Stack-specific config & encrypted secrets for `dev`
├── pyproject.toml       # Python dependencies managed by uv
├── uv.lock              # Reproducible lockfile managed by uv
└── __main__.py          # Entrypoint where infrastructure resources are declared
```

### Example `Pulumi.yaml`

```yaml
name: my-infra
description: AWS infrastructure managed by Pulumi
runtime:
  name: python
  options:
    toolchain: uv
backend:
  url: s3://my-pulumi-state-bucket?region=us-east-1&awssdk=v2
```

### Managing Dependencies with `uv`

Always manage dependencies and the project environment with `uv`:

```bash
# Add AWS providers or helper libraries
uv add pulumi-aws pulumi-awsx

# Sync environment from uv.lock (e.g., after pulling changes)
uv sync

# Refresh lockfile after manual pyproject.toml edits
uv lock

# Run ad-hoc scripts inside the project environment
uv run python scripts/verify.py
```

---

## 3. Essential CLI Cheat Sheet

### Stack Lifecycle

```bash
pulumi stack init staging          # Create and select a new stack
pulumi stack ls                    # List stacks in the current project
pulumi stack select dev            # Switch active stack
pulumi stack output                # Show exported outputs for active stack
pulumi stack output bucket_name    # Print a single output value
pulumi stack rm staging            # Remove an empty stack and its state
```

### Configuration & Secrets

```bash
pulumi config set aws:region us-east-1          # Set provider-namespaced config
pulumi config set env dev                       # Set project-namespaced config (my-infra:env)
pulumi config set --secret dbPassword "s3cr3t"  # Encrypt and store secret in Pulumi.<stack>.yaml
pulumi config set --path 'vpc.cidr' 10.0.0.0/16 # Set nested YAML config value
pulumi config get env                           # Read a config value
pulumi config                                   # List all config values (secrets masked)
```

### Deployment Lifecycle

```bash
pulumi preview          # Dry-run: compute diff without changing cloud resources
pulumi up               # Preview and apply changes (prompts for confirmation)
pulumi up --yes         # Apply non-interactively (CI/CD)
pulumi refresh          # Reconcile state file with actual live cloud state
pulumi destroy          # Tear down all resources in the active stack
pulumi logs             # Stream cloud logs (e.g., CloudWatch) for stack resources
```

---

## 4. Programming Model: Resources, Inputs & Outputs

### Declaring Resources & Naming

Every resource takes a **logical name** (first positional argument) used by Pulumi to track identity in state, plus cloud properties:

```python
import pulumi
import pulumi_aws as aws

bucket = aws.s3.Bucket(
    "app-assets",  # Logical name (Pulumi auto-generates physical name: app-assets-a1b2c3d)
    tags={"Environment": "dev"},
)
```

* **Logical name (`"app-assets"`)**: Identifies the resource inside Pulumi's state. Changing it tells Pulumi to create a new resource and delete the old one (unless you configure `aliases`).
* **Physical name (`bucket="..."`)**: Optional. If omitted, Pulumi **auto-names** resources with a random suffix so replacements can safely happen before deletions.

### Understanding `Output[T]`

Cloud attributes like `.id`, `.arn`, or `.bucket_domain_name` are not known when Python starts executing—they resolve asynchronously during `pulumi up`. Pulumi represents them as `pulumi.Output[T]`.

#### 1. Pass `Output[T]` directly as inputs (implicit dependencies)

When you pass an `Output` into another resource, Pulumi automatically builds the dependency graph (`depends_on` is inferred):

```python
aws.s3.BucketVersioning(
    "app-assets-versioning",
    bucket=bucket.id,  # Output[str] passed directly as Input[str]
    versioning_configuration={"status": "Enabled"},
)
```

#### 2. String interpolation (`Output.concat` and `Output.format`)

```python
bucket_uri = pulumi.Output.concat("s3://", bucket.bucket, "/uploads")
endpoint_msg = pulumi.Output.format("Bucket {0} is in {1}", bucket.id, bucket.region)
```

#### 3. Transforming outputs (`.apply`)

Use `.apply()` to transform a resolved value—for example, building a JSON IAM policy document:

```python
import json

policy_doc = bucket.arn.apply(
    lambda arn: json.dumps(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": ["s3:GetObject"],
                    "Resource": [f"{arn}/*"],
                }
            ],
        }
    )
)
```

#### 4. Combining multiple outputs (`Output.all`)

```python
combined = pulumi.Output.all(bucket.bucket, bucket.arn).apply(
    lambda args: f"name={args[0]} arn={args[1]}"
)

# Keyword form is often clearer for multiple values:
combined_kw = pulumi.Output.all(name=bucket.bucket, arn=bucket.arn).apply(
    lambda args: f"name={args['name']} arn={args['arn']}"
)
```

#### 5. Exporting stack outputs

```python
pulumi.export("bucket_name", bucket.bucket)
pulumi.export("bucket_arn", bucket.arn)
```

---

## 5. Configuration & Secrets in Code

Use `pulumi.Config()` to read values from `Pulumi.<stack>.yaml`:

```python
import pulumi

config = pulumi.Config()

# Required vs optional values
env = config.require("env")                      # Fails early if missing
replicas = config.get_int("replicas") or 2       # Optional typed getter (returns None if unset)
enable_cdn = config.get_bool("enableCdn") or False

# Reading secrets (returns Output[str] marked as secret in state & logs)
db_password = config.require_secret("dbPassword")

# Reading another provider's namespace (e.g., aws:region)
aws_config = pulumi.Config("aws")
region = aws_config.require("region")
```

To mark any runtime-computed value as a secret so Pulumi encrypts it in state and redacts it in CLI output:

```python
secret_token = pulumi.Output.secret(raw_token_output)
```

---

## 6. `ResourceOptions` (`opts=pulumi.ResourceOptions(...)`)

Pass `opts` to control lifecycle, protection, dependencies, and state behavior:

```python
db = aws.rds.Instance(
    "main-db",
    engine="postgres",
    instance_class="db.t4g.micro",
    allocated_storage=20,
    opts=pulumi.ResourceOptions(
        protect=True,                        # Prevent accidental deletion or replacement
        depends_on=[vpc_gateway],            # Explicit dependency when no Output is wired
        parent=app_component,                # Group under a ComponentResource
        aliases=[pulumi.Alias(name="db")],   # Safely rename logical name without replacing resource
        ignore_changes=["allocated_storage"],# Ignore drift on externally managed fields
        retain_on_delete=True,               # Remove from state on destroy without deleting cloud resource
        # import_="my-existing-db-id",       # Adopt an existing cloud resource during `pulumi up`
    ),
)
```

| Option | Effect |
| :--- | :--- |
| `protect=True` | Blocks `destroy` or replacement updates until unprotected. |
| `depends_on=[...]` | Enforces creation order when resources don't share an `Output`. |
| `parent=...` | Nests resource under a parent `ComponentResource` in CLI tree and URNs. |
| `aliases=[...]` | Preserves existing cloud resource when renaming logical names or refactoring into components. |
| `ignore_changes=[...]` | Tells Pulumi to ignore diffs on specified properties. |
| `retain_on_delete=True` | Leaves the physical cloud resource intact when removed from code or destroyed. |
| `import_="..."` | Adopts an existing cloud resource by its provider ID. |

---

## 7. `ComponentResource` (Reusable Abstractions)

Subclass `pulumi.ComponentResource` to package related resources into a clean, reusable module with proper URN nesting and dependency propagation:

```python
import pulumi
import pulumi_aws as aws


class StaticSiteBucket(pulumi.ComponentResource):
    bucket_name: pulumi.Output[str]
    bucket_arn: pulumi.Output[str]

    def __init__(
        self,
        name: str,
        tags: dict[str, str] | None = None,
        opts: pulumi.ResourceOptions | None = None,
    ) -> None:
        # Type string format: "<namespace>:<module>:<TypeName>"
        super().__init__("custom:storage:StaticSiteBucket", name, None, opts)

        child_opts = pulumi.ResourceOptions(parent=self)

        bucket = aws.s3.Bucket(
            f"{name}-bucket",
            tags=tags or {},
            opts=child_opts,
        )

        aws.s3.BucketPublicAccessBlock(
            f"{name}-public-access-block",
            bucket=bucket.id,
            block_public_acls=True,
            block_public_policy=True,
            ignore_public_acls=True,
            restrict_public_buckets=True,
            opts=child_opts,
        )

        self.bucket_name = bucket.bucket
        self.bucket_arn = bucket.arn

        # Signals to Pulumi that all child resources are registered and exposes outputs
        self.register_outputs(
            {
                "bucket_name": self.bucket_name,
                "bucket_arn": self.bucket_arn,
            }
        )
```

Usage in `__main__.py`:

```python
site_bucket = StaticSiteBucket("marketing-site", tags={"Team": "platform"})
pulumi.export("site_bucket_name", site_bucket.bucket_name)
```

---

## 8. Stack References (Cross-Stack Communication)

Share outputs between separate projects/stacks (for example, a shared `network-infra` stack exporting a VPC ID to an `app` stack):

```python
import pulumi
import pulumi_aws as aws

# For Pulumi Cloud: "<org>/<project>/<stack>"
# For self-managed backends (S3): "organization/<project>/<stack>" or "<project>/<stack>"
network = pulumi.StackReference("organization/network-infra/prod")

vpc_id = network.get_output("vpc_id")
private_subnet_ids = network.get_output("private_subnet_ids")

sg = aws.ec2.SecurityGroup(
    "app-sg",
    vpc_id=vpc_id,
    description="App security group",
)
```

* Use `.require_output("vpc_id")` instead of `.get_output("vpc_id")` if you want deployment to fail immediately when the output is missing.

---

## 9. State Surgery & Importing Existing Infrastructure

### Importing Existing Cloud Resources

Use `pulumi import` to adopt a resource into state **and** generate the matching Python code:

```bash
# Syntax: pulumi import <type-token> <logical-name> <cloud-resource-id>
pulumi import aws:s3/bucket:Bucket legacy-uploads my-existing-legacy-bucket
```

Alternatively, declare the resource in Python matching the cloud state and pass `opts=pulumi.ResourceOptions(import_="my-existing-legacy-bucket")`, run `pulumi up`, then remove `import_`.

### Repairing or Editing State

```bash
# List resources and their URNs in the current stack
pulumi stack --show-urns

# Remove a resource from state WITHOUT deleting it in AWS
pulumi state delete 'urn:pulumi:dev::my-infra::aws:s3/bucket:Bucket::app-assets'

# Unprotect a protected resource so it can be destroyed or replaced
pulumi state unprotect 'urn:pulumi:dev::my-infra::aws:rds/instance:Instance::main-db'

# Export/import raw state JSON (backup or manual surgery)
pulumi stack export --file state.json
pulumi stack import --file state.json

# Clear a stale lock after an interrupted `pulumi up` (ensure no deploy is still running)
pulumi cancel
```

---

## 10. Common Pitfalls & Best Practices

1. **Never call `str(output)` or f-strings directly on an `Output[T]`**
   * `f"arn:{bucket.arn}"` evaluates to `"arn:<pulumi.output.Output object at 0x...>"`, not the resolved ARN.
   * **Fix:** Use `pulumi.Output.concat(...)`, `pulumi.Output.format(...)`, or `.apply(...)`.

2. **Avoid creating resources or running side effects inside `.apply()`**
   * `.apply()` does not execute when values are unknown during `pulumi preview`, so resources created inside `.apply()` are invisible in previews and can behave inconsistently.
   * **Fix:** Declare resources at the top level and pass `Output`s into their arguments.

3. **Embrace auto-naming**
   * Letting Pulumi suffix physical names (`app-assets-a1b2c3d`) enables zero-downtime **create-before-delete** replacements and prevents naming collisions across `dev`/`staging`/`prod` stacks.
   * Only hardcode a physical name (e.g., `bucket="my-fixed-name"`) when external DNS or legacy integrations strictly require an immutable name.

4. **Check `pulumi preview` before every `pulumi up`**
   * Pay special attention to `replace` (`+-`) operations on stateful resources like RDS databases, S3 buckets, or KMS keys—use `protect=True` on critical stateful resources.

5. **Keep stacks small and cohesive**
   * Split slow-changing foundational resources (VPCs, DNS, IAM roles) from fast-changing application stacks (ECS services, Lambdas) and wire them together with `StackReference`.
