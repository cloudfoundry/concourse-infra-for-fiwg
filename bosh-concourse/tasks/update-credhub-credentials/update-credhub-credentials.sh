#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${PWD}"
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

TERRAFORM_OUTPUTS="${WORKSPACE_DIR}/terraform/metadata"
JUMPBOX_CREDS="${WORKSPACE_DIR}/jumpbox-creds/creds.yml"
DIRECTOR_CREDS="${WORKSPACE_DIR}/director-creds/creds.yml"

terraform_output() {
  output=$1
  jq -r ".${output}" "${TERRAFORM_OUTPUTS}"
}

director_cred() {
  path=$1
  bosh int "${DIRECTOR_CREDS}" --path="${path}"
}

jumpbox_cred() {
  path=$1
  bosh int "${JUMPBOX_CREDS}" --path="${path}"
}

jumpbox_ip="$(terraform_output "jumpbox_ip")"

director_ip="$(terraform_output "internal_director_ip")"
director_admin_password="$(director_cred "/admin_password")"
director_credhub_admin_secret="$(director_cred "/credhub_admin_client_secret")"

director_ca_path=$(mktemp)
echo "$(director_cred "/director_ssl/ca")" >"${director_ca_path}"

director_credhub_ca=$(mktemp)
echo "$(director_cred "/credhub_tls/ca")" >"${director_credhub_ca}"
echo "$(director_cred "/uaa_ssl/ca")" >>"${director_credhub_ca}"

jumpbox_private_key_path=$(mktemp)
echo "$(jumpbox_cred "/jumpbox_ssh/private_key")" >"${jumpbox_private_key_path}"

export BOSH_ENVIRONMENT="${director_ip}"
export BOSH_CA_CERT="${director_ca_path}"
export BOSH_CLIENT="admin"
export BOSH_CLIENT_SECRET="${director_admin_password}"
export BOSH_ALL_PROXY="ssh+socks5://jumpbox@${jumpbox_ip}:22?private-key=${jumpbox_private_key_path}"

export CREDHUB_PROXY="${BOSH_ALL_PROXY}"
export CREDHUB_CLIENT="credhub-admin"
export CREDHUB_SECRET="${director_credhub_admin_secret}"
export CREDHUB_SERVER="${director_ip}:8844"
export CREDHUB_CA_CERT="${director_credhub_ca}"

director_credhub_server="${CREDHUB_SERVER}"
director_credhub_client="${CREDHUB_CLIENT}"
director_credhub_secret="${CREDHUB_SECRET}"

concourse_credhub_admin_secret="$(credhub get -n /concourse/concourse/credhub_admin_secret -q)"
ci_user_password="$(credhub get -n /concourse/concourse/ci_user_password -q)"

credhub_web_instance="$(bosh -d concourse is --details --json | jq -r '.Tables[].Rows[] | select( .instance | contains("web")) | select( .index == "0").ips')"

export CREDHUB_CLIENT=credhub_admin
export CREDHUB_SECRET="${concourse_credhub_admin_secret}"
export CREDHUB_SERVER="${credhub_web_instance}:8844"

# Needed because the certificate does not have valid SAN for the local IP we're using to talk to it
# The credhub cli will save the certs into ~/.credhub/config.json so it continues working
credhub login --skip-tls-validation

credhub set -n /concourse/main/deploy-concourse/director_admin -t user --username=admin --password="${BOSH_CLIENT_SECRET}"
credhub set -n /concourse/main/deploy-concourse/director_target -t value --value="${director_ip}"
credhub set -n /concourse/main/deploy-concourse/director_ca_cert -t certificate --root="${director_ca_path}" --certificate="${director_ca_path}"
credhub set -n /concourse/main/deploy-concourse/jumpbox_url -t value --value="${jumpbox_ip}:22"
credhub set -n /concourse/main/deploy-concourse/jumpbox_ssh -t ssh --private="${jumpbox_private_key_path}"
credhub set -n /concourse/main/deploy-concourse/jumpbox_username -t value --value=jumpbox
credhub set -n /concourse/main/deploy-concourse/credhub_admin -t user --username="${CREDHUB_CLIENT}" --password="${CREDHUB_SECRET}"
credhub set -n /concourse/main/deploy-concourse/credhub_server -t value --value="${CREDHUB_SERVER}"
credhub set -n /concourse/main/deploy-concourse/director_credhub_admin -t user --username="${director_credhub_client}" --password="${director_credhub_secret}"
credhub set -n /concourse/main/deploy-concourse/director_credhub_server -t value --value="${director_credhub_server}"
credhub set -n /concourse/main/deploy-concourse/director_credhub_ca_cert -t certificate --root="${director_credhub_ca}" --certificate="${director_credhub_ca}"
credhub set -n /concourse/main/deploy-concourse/concourse_ci_user -t user --username=ci-user --password="${ci_user_password}"
