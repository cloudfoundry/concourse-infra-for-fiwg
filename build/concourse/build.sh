#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "Generating Concourse resource definitions..."

helm template concourse -f "${SCRIPT_DIR}/values.yml" \
     "${SCRIPT_DIR}/_vendir" \
     | ytt --ignore-unknown-comments -f - -f "${SCRIPT_DIR}/scrub_default_creds.yml" \
     > "${SCRIPT_DIR}/../../config/concourse/_ytt_lib/concourse/rendered.yml"
