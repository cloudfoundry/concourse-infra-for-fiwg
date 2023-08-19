#!/bin/bash

set -eux

dir=$(dirname $0)

fly -t bosh set-pipeline \
	-p deploy-concourse \
	-c $dir/deploy-concourse.yml
