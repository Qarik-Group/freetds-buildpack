#!/bin/bash

set -e

# either set $VERSION, or pass in from ${VERSION_FROM} file (e.g. concourse resource)
VERSION=${VERSION:-$(cat ${VERSION_FROM})}
S3_BUCKET=${S3_BUCKET:-freetds-buildpack}
S3_REGION=${S3_REGION:-us-east-2}

: ${SRC_DIR:?required}
: ${OUTPUT_DIR:?required}
TMP_SRC_DIR=${TMP_DIR:-tmp/src}
TMP_BUILD_DIR=${TMP_DIR:-tmp/build}

SRC_ZIP=$PWD/$(ls $SRC_DIR/*.tar.gz)

SRC_DIR=$PWD/${SRC_DIR}
OUTPUT_DIR=$PWD/${OUTPUT_DIR}
TMP_SRC_DIR=$PWD/${TMP_SRC_DIR}
TMP_BUILD_DIR=$PWD/${TMP_BUILD_DIR}

mkdir -p $TMP_SRC_DIR
cd $TMP_SRC_DIR
rm -rf freetds-*/

tar xfz $SRC_ZIP
cd *freetds*/
./configure --prefix=${TMP_BUILD_DIR}
make
make install

mkdir -p $OUTPUT_DIR/blobs
mkdir -p $OUTPUT_DIR/manifest

cd $TMP_BUILD_DIR
tar cfz $OUTPUT_DIR/blobs/freetds-compiled-${VERSION}.tgz .
cd -

sha=$(sha256sum $OUTPUT_DIR/blobs/freetds-compiled-${VERSION}.tgz | awk '{print $1}')

cat > $OUTPUT_DIR/manifest/manifest.yml <<YAML
---
language: freetds
default_versions:
- name: freetds
  version: $VERSION
dependency_deprecation_dates: []

include_files:
  - README.md
  - VERSION
  - bin/supply
  - manifest.yml
pre_package: scripts/build.sh

dependencies:
- name: freetds
  version: $VERSION
  uri: https://${S3_BUCKET}.s3.${S3_REGION}.amazonaws.com/blobs/freetds/freetds-compiled-$VERSION.tgz
  sha256: ${sha}
  cf_stacks:
  - cflinuxfs3
YAML