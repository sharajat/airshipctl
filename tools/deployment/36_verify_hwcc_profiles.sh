#!/usr/bin/env bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x

export KUBECONFIG=${KUBECONFIG:-"$HOME/.airship/kubeconfig"}
export KUBECONFIG_TARGET_CONTEXT=${KUBECONFIG_TARGET_CONTEXT:-"target-cluster"}
PROFILE="hardwareclassification-profile"
PROFILE_NAME="profile"
declare UNMATCH=0
declare MATCH=0

# HWCC need BMH in Ready state.
for i in {1..2}
do
# Verifying profile match status.
  OUTPUT=$(kubectl --kubeconfig $KUBECONFIG --context $KUBECONFIG_TARGET_CONTEXT get bmh -l hardwareclassification.metal3.io/${PROFILE}$i 2>&1)
  if [[ $? -eq 0 ]]; then
    echo ${OUTPUT} | grep "No resources found"
    if [[ $? -eq 0 ]]; then
      UNMATCH=1
    else
      MATCH=1
    fi
  fi
done

if [ ${MATCH} == 1 ] && [ ${UNMATCH} == 1 ]; then
  echo "${PROFILE_NAME}1 Matched and ${PROFILE_NAME}2 Unmatched."
  echo "SUCCESS"
else
  echo "FAILURE"
  exit 1
fi
