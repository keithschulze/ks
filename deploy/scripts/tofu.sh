#!/usr/bin/env bash

fn_get_tf_state_bucket() (
  aws ssm get-parameter \
    --name "$TF_STATE_BUCKET_SSM_PATH" \
    --output text \
    --query Parameter.Value
)

fn_get_tf_state_lock_table() (
  aws ssm get-parameter \
    --name "$TF_STATE_LOCK_TABLE_SSM_PATH" \
    --output text \
    --query Parameter.Value
)

tofu_init() (

  echo "Region: $AWS_REGION"
  echo "State Bucket: $(fn_get_tf_state_bucket)"
  echo "State Lock Table: $(fn_get_tf_state_lock_table)"
  echo "App Name: $TF_VAR_app_name"
  echo "Deploy Env: $TF_VAR_deploy_env"
  echo "Workspace Key Prefix: $TF_WORKSPACE_KEY_PREFIX"

  tofu init ${TF_RECONFIGURE:+-reconfigure} ${TF_UPGRADE:+-upgrade} \
    -backend-config="region=$AWS_REGION" \
    -backend-config="bucket=$(fn_get_tf_state_bucket)" \
    -backend-config="dynamodb_table=$(fn_get_tf_state_lock_table)" \
    -backend-config="key=$TF_VAR_app_name/$TF_VAR_deploy_env/base.tfstate" \
    -backend-config="workspace_key_prefix=$TF_WORKSPACE_KEY_PREFIX" \
    --input=false
)

if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
    export -f tofu_init
else
    tofu_init "${@}"
    exit $?
fi
