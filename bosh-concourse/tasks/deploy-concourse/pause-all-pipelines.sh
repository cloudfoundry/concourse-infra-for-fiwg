#!/usr/bin/env bash
set -euo pipefail

wget --quiet -O /usr/local/bin/fly "${CONCOURSE_URL}/api/v1/cli?arch=amd64&platform=linux"
chmod +x /usr/local/bin/fly

for team in ${TEAMS}
do
  fly --target concourse login --concourse-url="${CONCOURSE_URL}" --username="${CONCOURSE_USERNAME}" --password="${CONCOURSE_PASSWORD}" --team-name="${team}"

  echo "Pausing unpaused pipelines in team: ${team}"
  fly --target concourse pipelines --json | jq -r '.[]|select(.paused | not)|select(.name != env.EXCLUDE_PIPELINE)|.name' | tee -a "paused-pipelines/${team}" | xargs --no-run-if-empty -n1 fly --target concourse pause-pipeline --pipeline
done

pushd paused-pipelines
  tar czf pipelines.tgz ./*
popd
