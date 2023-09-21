#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${PWD}"

TERRAFORM_OUTPUTS="${WORKSPACE_DIR}/terraform/metadata"

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
internal_jumpbox_ip="$(terraform_output "internal_jumpbox_ip")"
gcp_credentials_file=$(mktemp)
echo "${GCP_CREDENTIALS_JSON}" > "${gcp_credentials_file}"

bosh create-env "${WORKSPACE_DIR}/jumpbox-deployment/jumpbox.yml" \
  -o "${WORKSPACE_DIR}/jumpbox-deployment/gcp/cpi.yml" \
  --state "${WORKSPACE_DIR}/jumpbox-state/state.json" \
  --vars-store "${WORKSPACE_DIR}/jumpbox-creds/creds.yml" \
  -v external_ip="${jumpbox_ip}" \
  -v zone="${zone}" \
  -v network="${network}" \
  -v subnetwork="${subnetwork}" \
  -v project_id="${project_id}" \
  -v internal_cidr="${internal_cidr}" \
  -v internal_gw="${internal_gw}" \
  -v internal_ip="${internal_jumpbox_ip}" \
  -v tags='["jumpbox"]' \
  --var-file=gcp_credentials_json="${gcp_credentials_file}"
