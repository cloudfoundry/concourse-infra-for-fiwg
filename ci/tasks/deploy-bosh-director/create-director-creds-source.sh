#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${PWD}"
DIRECTOR_CREDS="${WORKSPACE_DIR}/director-creds/creds.yml"

director_cred() {
  path=$1
  bosh int "${DIRECTOR_CREDS}" --path="${path}"
}

mbus_bootstrap_password="$(director_cred "/mbus_bootstrap_password")"
mbus_ca="$(director_cred "/mbus_bootstrap_ssl/ca")"

cat > "${WORKSPACE_DIR}/director-creds-source/creds-source.sh" <<EOF
jumpbox_private_key_path=\$(mktemp)

echo "${JUMPBOX_PRIVATE_KEY}" > \${jumpbox_private_key_path}

export BOSH_ALL_PROXY="ssh+socks5://${JUMPBOX_USERNAME}@${JUMPBOX_URL}?private-key=\${jumpbox_private_key_path}"
export BOSH_CA_CERT="${BOSH_CA_CERT}"
export BOSH_CLIENT="${BOSH_CLIENT}"
export BOSH_CLIENT_SECRET="${BOSH_CLIENT_SECRET}"
export BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"
export BOSH_AGENT_ENDPOINT="https://mbus:${mbus_bootstrap_password}@${BOSH_ENVIRONMENT}:6868"
export BOSH_AGENT_CERTIFICATE="${mbus_ca}"
export CREDHUB_CLIENT="${CREDHUB_CLIENT}"
export CREDHUB_SECRET="${CREDHUB_SECRET}"
export CREDHUB_SERVER="${CREDHUB_SERVER}"
export CREDHUB_PROXY="ssh+socks5://${JUMPBOX_USERNAME}@${JUMPBOX_URL}?private-key=\${jumpbox_private_key_path}"
export CREDHUB_CA_CERT="${CREDHUB_CA_CERT}"
EOF
