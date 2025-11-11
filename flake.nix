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

        tofuInit = (pkgs.writeScriptBin "tofu-init" (builtins.readFile ./deploy/scripts/tofu.sh)).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in {
        defaultPackage = pkgs.blog;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            awscli2
            opentofu
            tofuInit
            jq
            zola

            # keep this line if you use bash
            bashInteractive
          ];

          AWS_REGION = awsRegion;
          AWS_DEFAULT_REGION = awsRegion;
          APP_NAME = appName;
          DEPLOY_ENV = deployEnv;
          TF_STATE_BUCKET_SSM_PATH = tfStateBucketSSMPath;
          TF_STATE_LOCK_TABLE_SSM_PATH = tfStateLockSSMPath;
          TF_WORKSPACE_KEY_PREFIX = tfWorkspacePrefix;
          TF_VAR_app_name = appName;
          TF_VAR_deploy_env = deployEnv;
          TF_VAR_region = awsRegion;
        };
      });
}
