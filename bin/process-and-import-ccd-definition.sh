#!/usr/bin/env bash

set -eu

scriptPath=$(dirname $(realpath $0))
basePath=$(dirname $(dirname $scriptPath))

ccdDefinitionRepoPath=${basePath}/prl-dev-env/prl-ccd-definitions

ccdDefinitionPath=$ccdDefinitionRepoPath/definitions/private-law/json
definitionOutputFile="${ccdDefinitionRepoPath}/build/ccd-development-config/ccd-prl-dev.xlsx"
params="$@"

cd $basePath

echo "Definition directory: ${ccdDefinitionPath}"
echo "Definition spreadsheet ${definitionOutputFile}"
echo "Additional parameters: ${params}"

mkdir -p $(dirname ${definitionOutputFile})

echo "directory created"
${scriptPath}/utils/process-definition.sh $ccdDefinitionPath $definitionOutputFile "${params}"
echo "processing done"
${scriptPath}/utils/ccd-import-definition.sh $definitionOutputFile