#!/bin/bash

BRANCH=$1

source ./ci/config.sh

# Avoid permissions problem.
chmod 600 ./ci/id_rsa_ci
ssh -i ./ci/id_rsa_ci -o "StrictHostKeyChecking no" ${CI_USER}@${CI_SERVER} "cd ${SCRIPTS_DIR} && ./build.sh ${BRANCH}"

