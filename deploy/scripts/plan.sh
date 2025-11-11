#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

source "$script_dir/tofu.sh"

tf_plan_output_dir=$(mktemp -d)
tf_plan_path="$tf_plan_output_dir/out.tfplan"
trap "rm -R ${tf_plan_output_dir}" EXIT

pushd "$script_dir/../tf"

tofu_init

tofu plan --input=false --out="$tf_plan_path"

popd
