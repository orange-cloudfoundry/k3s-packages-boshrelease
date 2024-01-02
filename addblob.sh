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
addBlobOnChecksumChange src/github.com/k3s-io/k3s/k3s-airgap-images-amd64.tar k3s-images/k3s-airgap-images-amd64.tar
chmod ugo+x src/github.com/kubernetes/kubectl/kubectl
addBlobOnChecksumChange src/github.com/kubernetes/kubectl/kubectl kubectl/kubectl


if [ "${NEW_BLOBS_WERE_ADDED}" == "true" ] ; then
  # See https://bosh.io/docs/release-blobs/#saving-blobs
  bosh upload-blobs
fi