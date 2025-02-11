#!/bin/bash
set -e

FLAGS=""

if [[ -z "$INPUT_CONFIG_FILE" ]]; then
  echo "Set the configuration file path."
else
  FLAGS="${FLAGS} -c $INPUT_CONFIG_FILE"
fi

if [[ -z "$INPUT_REPOSITORY_URL" ]] && [[ -z "$INPUT_REPOSITORY_LOCAL" ]];
then
  echo "You need to set either remote repository or repository local flags."
fi

if [[ ! -z "$INPUT_REPOSITORY_URL" ]]; then
  FLAGS="${FLAGS} -r $INPUT_REPOSITORY_URL"
fi

if [[ ! -z "$INPUT_REPOSITORY_LOCAL" ]]; then
  FLAGS="${FLAGS} -l"
fi

if [[ ! -z "$INPUT_STRICT" ]]; then
  FLAGS="${FLAGS} -s"
fi

if [[ ! -z "$INPUT_EXISTING" ]]; then
  FLAGS="${FLAGS} -e"
fi

if [[ "${FLAGS}" == "" && "$*" == "" ]]; then
  exit 1
fi

if [[ ! -z "$INPUT_GITHUB_TOKEN" ]]; then
  export GITHUB_TOKEN=$INPUT_GITHUB_TOKEN
fi

if [[ ! -z "$INPUT_GITHUB_USERNAME" ]]; then
  export GITHUB_USERNAME=$INPUT_GITHUB_USERNAME
fi

cd /github/workspace
OUT_SEMVER_GEN=$(/go/src/app/semver-gen generate $FLAGS $*)
[ $? -eq 0 ] || exit 1
CLEAN_SEMVER=$(echo $OUT_SEMVER_GEN | sed -e 's|SEMVER ||g')
echo "semantic_version=$CLEAN_SEMVER" >> $GITHUB_OUTPUT
echo $OUT_SEMVER_GEN