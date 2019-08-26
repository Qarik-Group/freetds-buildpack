#!/bin/bash

set -euo pipefail

GO_VERSION="1.12.9"

if [ $CF_STACK == "cflinuxfs2" ]; then
    GO_SHA256="a04ab0d3c9beba3bc792055e84aa2dfa0b6205b176a2044db9c366cae31cc958"
elif [ $CF_STACK == "cflinuxfs3" ]; then
    GO_SHA256="14ae7a7109e144cd7f5fddd369b32b8c6fb5bad37c384c13990264931d33263d"
else
  echo "       **ERROR** Unsupported stack"
  echo "                 See https://docs.cloudfoundry.org/devguide/deploy-apps/stacks.html for more info"
  exit 1
fi

export GoInstallDir="/tmp/go$GO_VERSION"
mkdir -p $GoInstallDir

if [ ! -f $GoInstallDir/go/bin/go ]; then
  URL=https://buildpacks.cloudfoundry.org/dependencies/go/go${GO_VERSION}.linux-amd64-${CF_STACK}-${GO_SHA256:0:8}.tar.gz

  echo "-----> Download go ${GO_VERSION}"
  curl -s -L --retry 15 --retry-delay 2 $URL -o /tmp/go.tar.gz

  DOWNLOAD_SHA256=$(shasum -a 256 /tmp/go.tar.gz | cut -d ' ' -f 1)

  if [[ $DOWNLOAD_SHA256 != $GO_SHA256 ]]; then
    echo "       **ERROR** SHA256 mismatch: got $DOWNLOAD_SHA256 expected $GO_SHA256"
    exit 1
  fi

  tar xzf /tmp/go.tar.gz -C $GoInstallDir
  rm /tmp/go.tar.gz
fi
if [ ! -f $GoInstallDir/go/bin/go ]; then
  echo "       **ERROR** Could not download go"
  exit 1
fi
