#!/usr/bin/env bash
set -euo pipefail


wget --quiet -O /usr/local/bin/fly "${CONCOURSE_URL}/api/v1/cli?arch=amd64&platform=linux"
chmod +x /usr/local/bin/fly

mkdir pipelines

tar xzf paused-pipelines/pipelines.tgz -C pipelines

for pipeline_list in pipelines/*
do
  team=$(basename "${pipeline_list}")
  fly --target concourse login --concourse-url="${CONCOURSE_URL}" --username="${CONCOURSE_USERNAME}" --password="${CONCOURSE_PASSWORD}" --team-name="${team}"

  echo "Unpausing pipelines in team: ${team}"
  while read -r pipeline; do
    fly --target concourse unpause-pipeline --pipeline="${pipeline}"
  done <"${pipeline_list}"
done
