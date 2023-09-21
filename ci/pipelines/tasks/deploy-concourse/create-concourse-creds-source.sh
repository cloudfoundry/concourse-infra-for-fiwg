#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${PWD}"

cat > "${WORKSPACE_DIR}/concourse-creds-source/creds-source.sh" <<EOF
jumpbox_private_key_path=\$(mktemp)

echo "${JUMPBOX_PRIVATE_KEY}" > \${jumpbox_private_key_path}

export CREDHUB_CLIENT="credhub_admin"
export CREDHUB_SECRET="$(credhub get -n /concourse/concourse/credhub_admin_secret -q)"
export CREDHUB_SERVER="${WEB_IP}:8844"
export CREDHUB_PROXY="ssh+socks5://${JUMPBOX_USERNAME}@${JUMPBOX_URL}?private-key=\${jumpbox_private_key_path}"
export CREDHUB_CA_CERT="$(credhub get -n /concourse/concourse/atc_tls -q -k ca)"
EOF
