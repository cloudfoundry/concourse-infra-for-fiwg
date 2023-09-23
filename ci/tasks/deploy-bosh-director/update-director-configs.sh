#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${PWD}"
SCRIPT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

TERRAFORM_OUTPUTS="${WORKSPACE_DIR}/terraform/metadata"

terraform_output() {
  output="${1}"
  jq -r ".${output}" "${TERRAFORM_OUTPUTS}"
}

director_ca_path=$(mktemp)
echo "${BOSH_CA_CERT}" > "${director_ca_path}"
export BOSH_CA_CERT="${director_ca_path}"

jumpbox_key_path=$(mktemp)
echo "${JUMPBOX_PRIVATE_KEY}" > "${jumpbox_key_path}"

export BOSH_ALL_PROXY="ssh+socks5://jumpbox@${JUMPBOX_URL}?private-key=${jumpbox_key_path}"

pushd "${SCRIPT_DIR}/.." > /dev/null
  concourse_web_target_pool="$(terraform_output "concourse_web_target_pool")"
  internal_cidr="$(terraform_output "internal_cidr")"
  internal_director_ip="$(terraform_output "internal_director_ip")"
  internal_gw="$(terraform_output "internal_gw")"
  internal_jumpbox_ip="$(terraform_output "internal_jumpbox_ip")"
  network="$(terraform_output "network")"
  subnetwork="$(terraform_output "subnetwork")"
  subnet_id="$(terraform_output "bosh_subnet_id")"
  az="$(terraform_output "az")"
  zone="$(terraform_output "zone")"
  security_group="$(terraform_output "security_group")"
popd > /dev/null

bosh -n update-cloud-config "${CLOUD_CONFIG_PATH}" \
  -v az="${az}" \
  -v zone="${zone}" \
  -v network="${network}" \
  -v vnet_name="${network}" \
  -v subnetwork="${subnetwork}" \
  -v subnet_id="${subnet_id}" \
  -v subnet_name="${subnetwork}" \
  -v security_group="${security_group}" \
  -v internal_cidr="${internal_cidr}" \
  -v internal_gw="${internal_gw}" \
  -v internal_jumpbox_ip="${internal_jumpbox_ip}" \
  -v internal_director_ip="${internal_director_ip}" \
  -v concourse_web_target_pool="${concourse_web_target_pool:-NONE}"

bosh -n update-runtime-config \
  --name dns \
  "${WORKSPACE_DIR}/bosh-deployment/runtime-configs/dns.yml"
