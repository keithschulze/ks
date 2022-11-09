#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

source "$script_dir/shared/terraform.sh"

pushd "$script_dir/../tf"

init_terraform

bucketName=$(terraform output -json | jq -r '.bucket_name.value')

popd

echo "Syncing content to ${bucketName}..."
aws s3 sync result "s3://${bucketName}"
