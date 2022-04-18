#!/usr/bin/env bash

scriptPath=$(dirname $(realpath $0))

# Roles used during the CCD import
${scriptPath}/utils/add-ccd-role.sh "caseworker"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-superuser"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-courtadmin-la"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-solicitor"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-courtadmin"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-pcqextractor"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-systemupdate"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-bulkscan"
${scriptPath}/utils/add-ccd-role.sh "payments"
${scriptPath}/utils/add-ccd-role.sh "pui-case-manager"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-judge"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-bulkscansystemupdate"
${scriptPath}/utils/add-ccd-role.sh "caseworker-privatelaw-la"
