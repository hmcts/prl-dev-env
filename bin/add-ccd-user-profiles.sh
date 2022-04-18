#!/usr/bin/env bash

read -r -d '' CCD_USERS << EOM
prl_local_caseworker@mailinator.com|PRIVATELAW|PRLAPPS|DRAFT
prl_test_caseworker@mailinator.com|PRIVATELAW|PRLAPPS|DRAFT
prl_local_solicitor@mailinator.com|PRIVATELAW|PRLAPPS|DRAFT
prl_caseworker_admin@mailinator.com|PRIVATELAW|PRLAPPS|DRAFT
prl_local_sysupdate@mailinator.com|PRIVATELAW|PRLAPPS|DRAFT
TEST_SYSTEM_USER@mailinator.com|PRIVATELAW|PRLAPPS|DRAFT
fprl_caseworker_solicitor@mailinator.com|PRIVATELAW|PRLAPPS|DRAFT
EOM

echo "Getting service_token from s2s"
dir=$(dirname ${0})
serviceToken=$(${dir}/utils/s2s-token.sh ccd_data)

users=$(echo "${CCD_USERS}" | tr "," "\n")
for user in $users
do
    echo "Adding \"$user\" ..."
    EMAIL=$(echo $user | cut -f1 -d'|')
    JURISDICTION=$(echo $user | cut -f2 -d'|')
    DEFAULT_CASE_TYPE=$(echo $user | cut -f3 -d'|')
    DEFAULT_CASE_STATE=$(echo $user | cut -f4 -d'|')
    post=$(curl --silent --show-error -X PUT ${CCD_USER_PROFILE_URL:-http://localhost:4453}/user-profile/users  -H "content-type: application/json" -H "ServiceAuthorization: Bearer ${serviceToken}" -d "[{\"id\": \"${EMAIL}\",\"work_basket_default_jurisdiction\": \"${JURISDICTION}\",\"work_basket_default_case_type\": \"${DEFAULT_CASE_TYPE}\",\"work_basket_default_state\": \"${DEFAULT_CASE_STATE}\"}]\"")
    echo "done: ${post}"
done