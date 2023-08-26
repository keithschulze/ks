{
  description = "keithschulze.com";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url   = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }:
    let
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };
    in {
      overlay = final: prev: {
        blog = prev.callPackage ./blog {};
      };

    } // utils.lib.eachDefaultSystem (system:
      let
        pkgs = pkgsFor system;

        appName = "ks";
        deployEnv = "dev";
        awsRegion = "ap-southeast-2";

        tfStateBucketSSMPath = "/ks-shared/tf/s3-state-bucket";
        tfStateLockSSMPath = "/ks-shared/tf/dynamodb-state-lock-table";
        tfWorkspacePrefix = "workspaces";

        tfCommon = (
          pkgs.writeScriptBin "terraform_common.sh" (
            builtins.readFile ./deploy/scripts/shared/terraform.sh
          )
        ).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in {
        defaultPackage = pkgs.blog;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            awscli2
            terraform
            jq
            zola

            # keep this line if you use bash
            bashInteractive
          ];

          shellHook = ''
            source "${tfCommon}/bin/terraform_common.sh"
            export AWS_REGION=${awsRegion}
            export AWS_DEFAULT_REGION=${awsRegion}
            export APP_NAME=${appName}
            export DEPLOY_ENV=${deployEnv}
            export OUTPUT_DIR=$out
            export TF_STATE_BUCKET_SSM_PATH=${tfStateBucketSSMPath}
            export TF_STATE_LOCK_TABLE_SSM_PATH=${tfStateLockSSMPath}
            export TF_WORKSPACE_KEY_PREFIX=${tfWorkspacePrefix}
            export TF_VAR_app_name=${appName}
            export TF_VAR_deploy_env=${deployEnv}
            export TF_VAR_region=${awsRegion}
            export TF_VAR_tf_state_bucket_name=$(fn_get_tf_state_bucket)
          '';
        };
      });
}
