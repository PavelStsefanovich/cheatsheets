# AWS CLI configuration and advanced usage

> This guide assumes AWS CLI v2

## Config


## S3

### Delete all objects in the versioned bucket
```bash
bucket=<bucket_name>
region=<region_name>

aws s3api list-object-versions \
          --bucket $bucket \
          --region $region \
          --query "Versions[].Key"  \
          --output json | jq 'unique' | jq -r '.[]' | while read key; do
   echo "deleting versions of $key"
   aws s3api list-object-versions \
          --bucket $bucket \
          --region $region \
          --prefix $key \
          --query "Versions[].VersionId"  \
          --output json | jq 'unique' | jq -r '.[]' | while read version; do
     echo "deleting $version"
     aws s3api delete-object \
          --bucket $bucket \
          --key $key \
          --version-id $version \
          --region $region
   done
done
```