#!/usr/bin/env bash

set -euo pipefail

echo "Syncing content to ${BUCKET_NAME}..."
aws s3 sync result "s3://${BUCKET_NAME}"
