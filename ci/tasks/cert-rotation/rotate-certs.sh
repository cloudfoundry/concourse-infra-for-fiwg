#!/usr/bin/env bash
set -euo pipefail
set -x

WORKSPACE_DIR="${PWD}"
SCRIPT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

vars_store=$(ls "${WORKSPACE_DIR}"/creds/*.yml)

# Do nothing if our creds file is empty
if [ ! -s "${vars_store}" ]; then
  exit 0
fi

desired_nats_certs="desired_nats_certs.yml"
# We may not have the next_nats_ca on the first rotation
if grep -q next_nats_server_tls "${vars_store}"; then
  bosh int "${SCRIPT_DIR}/nats-cert-rotation/capture-previous-nats-certs.yml" \
    --vars-file="${vars_store}" \
    > "${desired_nats_certs}"
else
  bosh int "${SCRIPT_DIR}/nats-cert-rotation/reuse-nats-certs-if-not-setup-for-rotation.yml" \
    --vars-file="${vars_store}" \
    > "${desired_nats_certs}"
fi

desired_blobstore_certs="desired_blobstore_certs.yml"
# We may not have the next_blobstore_ca on the first rotation
if grep -q next_blobstore_server_tls "${vars_store}"; then
  bosh int "${SCRIPT_DIR}/blobstore-cert-rotation/capture-previous-blobstore-certs.yml" \
    --vars-file="${vars_store}" \
    > "${desired_blobstore_certs}"
else
  bosh int "${SCRIPT_DIR}/blobstore-cert-rotation/reuse-blobstore-certs-if-not-setup-for-rotation.yml" \
    --vars-file="${vars_store}" \
    > "${desired_blobstore_certs}"
fi


ops=""

for cert in $(grep "ca: |" -B1 "${vars_store}" | grep -v "ca: |" | grep ':' | cut -d: -f1); do
    ops="${ops}"'- {"type":"remove","path":"/'"${cert}"'"}\n'
done
bosh int "${vars_store}" -o <(echo -e ${ops}) > "${vars_store}.tmp"
mv "${vars_store}.tmp" "${vars_store}"

arguments=""
if [ "${ROTATE_DIRECTOR}" != "false" ]; then
  if [ -d "${WORKSPACE_DIR}/terraform" ]; then
    terraform_outputs="${WORKSPACE_DIR}/terraform/metadata"
    director_ip="$(jq -r ".internal_director_ip" "${terraform_outputs}")"
    arguments="${arguments} -v internal_ip=${director_ip}"
  fi
  if [ -d "${WORKSPACE_DIR}/vars" ]; then
    vars_file=("${WORKSPACE_DIR}"/vars/*.yml)
    arguments="${arguments} --vars-file=${vars_file}"
  fi
  if [ "${EXTERNAL_IP}" != "false" ]; then
    arguments="${arguments} -o ${WORKSPACE_DIR}/bosh-deployment/external-ip-not-recommended.yml"
  fi

  # Regenerate all the missing certs
  # internal_ip is needed as it is part of the SAN for the nats_server_tls variable
  bosh int "${WORKSPACE_DIR}/bosh-deployment/bosh.yml" \
    --vars-store "${vars_store}" \
    ${arguments} \
    > /dev/null

  # Combine the new nats_ca, blobstore_ca and the previous copy
  bosh int "${vars_store}" \
    -o "${SCRIPT_DIR}/blobstore-cert-rotation/configure-vars-store-for-rotation.yml" \
    -o "${SCRIPT_DIR}/nats-cert-rotation/configure-vars-store-for-rotation.yml" \
    --vars-file="${vars_store}" \
    --vars-file="${desired_blobstore_certs}" \
    --vars-file="${desired_nats_certs}" \
    > "${vars_store}.tmp"
  mv "${vars_store}.tmp" "${vars_store}"
fi
