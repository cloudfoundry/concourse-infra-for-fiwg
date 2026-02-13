#!/bin/bash

set -eux

repo_dir=$(cd "$(dirname "${0}")/.." && pwd)

fly -t "${CONCOURSE_TARGET:-bosh}" set-pipeline \
	-p deploy-concourse \
	-c "${repo_dir}/ci/pipelines/deploy-concourse.yml"
