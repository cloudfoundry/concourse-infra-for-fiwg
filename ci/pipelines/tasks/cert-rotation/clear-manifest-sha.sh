#!/usr/bin/env bash
set -eu

state_file=$(ls ./state/*.json)

sed --in-place '/current_manifest_sha/d' "${state_file}"
