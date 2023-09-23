#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${PWD}"
SCRIPT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

TERRAFORM_OUTPUTS="${WORKSPACE_DIR}/terraform/metadata"
JUMPBOX_CREDS="${WORKSPACE_DIR}/jumpbox-creds/creds.yml"

terraform_output(){
  output=$1
  jq -r ".${output}" "${TERRAFORM_OUTPUTS}"
}

jumpbox_ip="$(terraform_output "jumpbox_ip")"
zone="$(terraform_output "zone")"
network="$(terraform_output "network")"
subnetwork="$(terraform_output "subnetwork")"
project_id="$(terraform_output "project_id")"
internal_cidr="$(terraform_output "internal_cidr")"
internal_gw="$(terraform_output "internal_gw")"
internal_director_ip="$(terraform_output "internal_director_ip")"

jumpbox_private_key=$(mktemp)
bosh int "${JUMPBOX_CREDS}" --path=/jumpbox_ssh/private_key > "${jumpbox_private_key}"

gcp_credentials_file=$(mktemp)
echo "${GCP_CREDENTIALS_JSON}" > "${gcp_credentials_file}"

export BOSH_ALL_PROXY="ssh+socks5://jumpbox@${jumpbox_ip}:22?private-key=${jumpbox_private_key}"

additional_ops_files=""
for ops_file in ${ADDITIONAL_OPS_FILES:-}; do
  additional_ops_files="${additional_ops_files} -o ${ops_file}"
done

bosh create-env "${WORKSPACE_DIR}/bosh-deployment/bosh.yml" \
  -o "${WORKSPACE_DIR}/bosh-deployment/gcp/cpi.yml" \
  -o "${WORKSPACE_DIR}/bosh-deployment/uaa.yml" \
  -o "${WORKSPACE_DIR}/bosh-deployment/credhub.yml" \
  -o "${WORKSPACE_DIR}/bosh-deployment/jumpbox-user.yml" \
  -o "${WORKSPACE_DIR}/bosh-community-ci-infra/ci/tasks/deploy-bosh-director/gcp-enable-external-ip.yml" \
  ${additional_ops_files} \
  --state "${WORKSPACE_DIR}/director-state/state.json" \
  --vars-store "${WORKSPACE_DIR}/director-creds/creds.yml" \
  -v director_name="concourse" \
  -v zone="${zone}" \
  -v network="${network}" \
  -v subnetwork="${subnetwork}" \
  -v project_id="${project_id}" \
  -v internal_cidr="${internal_cidr}" \
  -v internal_gw="${internal_gw}" \
  -v internal_ip="${internal_director_ip}" \
  -v tags='["bosh-deployed"]' \
  --var-file=gcp_credentials_json="${gcp_credentials_file}"
