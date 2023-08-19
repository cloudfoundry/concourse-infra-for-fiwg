#!/usr/bin/env bash
set -euo pipefail

wget --quiet -O /usr/local/bin/fly "${CONCOURSE_URL}/api/v1/cli?arch=amd64&platform=linux"
chmod +x /usr/local/bin/fly

fly --target concourse login --concourse-url="${CONCOURSE_URL}" --username="${CONCOURSE_USERNAME}" --password="${CONCOURSE_PASSWORD}"

while true; do
  running_job_count=$(fly --target concourse builds --count=1000 --json | jq '[.[] | select(.status == "started") | select(.job_name != env.IGNORE_JOB)] | length')
  if [  "${running_job_count}" -eq 0 ]; then
    echo "No more jobs running"
    break
  fi
  echo "Waiting on ${running_job_count} jobs to finish"
  sleep 60
done
