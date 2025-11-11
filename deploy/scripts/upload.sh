#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

source "$script_dir/tofu.sh"

pushd "$script_dir/../tf"

tofu_init

bucketName=$(tofu output -json | jq -r '.bucket_name.value')

popd

echo "Syncing content to ${bucketName}..."
aws s3 sync result "s3://${bucketName}"
