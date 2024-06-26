#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

source "$script_dir/shared/tofu.sh"

pushd "$script_dir/../tf"

init_tofu

bucketName=$(tofu output -json | jq -r '.bucket_name.value')

popd

echo "Syncing content to ${bucketName}..."
aws s3 sync result "s3://${bucketName}"
