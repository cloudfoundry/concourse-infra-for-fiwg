#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "Generating Quarks Secret resource definitions..."

helm template qsecret --namespace=concourse -f "${SCRIPT_DIR}/values.yml" \
     "${SCRIPT_DIR}/_vendir" \
     | ytt --ignore-unknown-comments -f - \
     > "${SCRIPT_DIR}/../../config/quarks-secret/_ytt_lib/quarks-secret/rendered.yml"
