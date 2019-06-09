#!/bin/bash

set -eu

: ${LIBRARY:?required}
: ${VERSION_FROM:?required}
: ${RELEASE_OUT:?required}
: ${NOTIFICATION_OUT:?required}
: ${REPO_URL:?required}

VERSION_FROM=${VERSION_FROM:-$REPO_ROOT/VERSION}
VERSION=$(cat ${VERSION_FROM})

REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

###############################################################

go get github.com/cloudfoundry/libbuildpack/packager/buildpack-packager

push $REPO_ROOT
source .envrc

rm -f *.zip
buildpack-packager summary
buildpack-packager -cached -stack cflinuxfs3
popd

mkdir -p ${RELEASE_OUT}/artifacts
echo "v${VERSION}"             > ${RELEASE_OUT}/tag
echo "${LIBRARY} v${VERSION}"  > ${RELEASE_OUT}/name
mv ${REPO_ROOT}/*.zip            ${RELEASE_OUT}/artifacts
buildpack-packager summary     > ${RELEASE_OUT}/notes.md

cat > ${NOTIFICATION_OUT}/message <<EOF
New ${LIBRARY} v${VERSION} released. <${REPO_URL}/releases/tag/v${VERSION}|Release notes>.
EOF
