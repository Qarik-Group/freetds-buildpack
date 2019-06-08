# Build FreeTDS within cflinuxfs3

Our buildpack users will need to download a pre-compiled version of [FreeTDS](https://www.freetds.org/). This Dockerfile describes how to compile FreeTDS and output it as a `tgz` file. Another part of the toolchain will upload the tgz to a public place, from which buildpack users will download it on demand.

```plain
VERSION=1.1.6
mkdir -p tmp/freetds-src
mkdir -p tmp/freetds-output
curl -L -o tmp/freetds-src/freetds-$VERSION.tar.gz ftp://ftp.freetds.org/pub/freetds/stable/freetds-$VERSION.tar.gz
docker run -ti \
  -e VERSION=${VERSION:?required} \
  -v $PWD:/buildpack \
  -v $PWD/tmp/freetds-src:/freetds-src \
  -v $PWD/tmp/freetds-output:/freetds-output \
  -e SRC_DIR=/freetds-src \
  -e OUTPUT_DIR=/freetds-output \
  cloudfoundry/cflinuxfs3 \
  /buildpack/scripts/freetds/compile.sh
```

Then upload new compiled blobs to your S3 account/bucket. In CI, this is performed with an `s3` resource.

```plain
bucket=freetds-buildpack
aws s3 cp --recursive tmp/freetds-output/blobs s3://$bucket/blobs/freetds
```

Finally, copy the new `manifest.yml` into this project:

```plain
cp tmp/freetds-output/manifest/manifest.yml manifest.yml
```