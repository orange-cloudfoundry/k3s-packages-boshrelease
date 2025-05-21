#!/bin/bash
set -x
set -e # exit on non-zero status

echo "Current blobs"
bosh blobs

NEW_BLOBS_WERE_ADDED="false"

# params
# $1: src
# $2: target
function addBlobOnChecksumChange() {
  src="$1"
  target="$2"
  blob_checksum=$(cat config/blobs.yml  | yq .'"'${target}'"'.sha)
  blob_object_id=$(cat config/blobs.yml  | yq .'"'${target}'"'.object_id) # With dev release, blobs are not publish yet, so we need to add it again
  src_checksum=$(cat "${src}"  | sha256sum |  cut -d " " -f1)
  if [ "${blob_checksum}" != "sha256:${src_checksum}" ] || [ "$blob_object_id" = "null" ]; then
    bosh add-blob ${src} ${target}
    NEW_BLOBS_WERE_ADDED="true"
  else
    echo "skipping blob creation for ${target} with existing checksum: ${src_checksum}"
  fi

}

addBlobOnChecksumChange src/github.com/k3s-io/k3s/k3s k3s/k3s
addBlobOnChecksumChange src/github.com/k3s-io/k3s/k3s-airgap-images-amd64.tar.gz k3s-images/k3s-airgap-images-amd64.tar.gz


# Inspired by https://github.com/orange-cloudfoundry/bosh-release-action/blob/8732ff085712d9980fc66e50892cb9c3d7a3f884/entrypoint.sh#L48-L58
function configureS3BlobStore() {
  if [ ! -z "${AWS_BOSH_ACCES_KEY_ID}" ]; then
    cat - > config/private.yml <<EOS
---
blobstore:
  options:
    access_key_id: ${AWS_BOSH_ACCES_KEY_ID}
    secret_access_key: ${AWS_BOSH_SECRET_ACCES_KEY}
EOS
  else
    echo "::warning::AWS_BOSH_ACCES_KEY_ID not set, skipping config/private.yml"
  fi
}

echo "Configuring S3 blobstore systematically: S3 credential are required during the bosh create-release to download the blobs"
configureS3BlobStore

if [ "${NEW_BLOBS_WERE_ADDED}" == "true" ] ; then
  echo "Current blobs before upload"
  bosh blobs

  # See https://bosh.io/docs/release-blobs/#saving-blobs
  bosh upload-blobs

  echo "Current blobs after upload"
  bosh blobs

fi