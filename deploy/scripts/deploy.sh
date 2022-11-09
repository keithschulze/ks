#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

source "$script_dir/shared/terraform.sh"

tf_plan_output_dir=$(mktemp -d)
tf_plan_path="$tf_plan_output_dir/out.tfplan"
trap "rm -R ${tf_plan_output_dir}" EXIT

pushd "$script_dir/../tf"

init_terraform

terraform plan --input=false --out="$tf_plan_path"

terraform apply --input=false "$tf_plan_path"

popd
