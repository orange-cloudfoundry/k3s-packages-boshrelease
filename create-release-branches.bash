#!/bin/bash
#set -x
set -e # exit on non-zero status

PUSH_OPTIONS=""
if [ $FORCE_PUSH = "true" ] ;then
  PUSH_OPTIONS="$PUSH_OPTIONS --force"
fi
current_version=$(yq -r '.directories[0].contents[] | select (.path=="k3s-io/k3s") | .githubRelease.tag ' ./vendir.yml)
current_version=${current_version#v}
MIN_VERSION=$(echo "$current_version"|cut -d'.' -f1-2)
for ref in $(git ls-remote -h https://github.com/k3s-io/k3s "release-*" | sed 's/refs\/heads\///' | awk '{print $2}') ; do
  v=${ref#release-}
  BRANCH_NAME="${ref}"
  echo "Extracted values - v: $v - BRANCH_NAME: $BRANCH_NAME"
  if [ $(echo "$v <= $MIN_VERSION"|bc) -eq 1 ];then
    echo "Skipping version $v"
    continue
  else
    echo "Keeping $v as $v > $MIN_VERSION"
  fi
  continue
  git branch -d "$BRANCH_NAME"
  git co -b "$BRANCH_NAME"
  sed -i.orig "s/tag: v.*/tag: v${v}.0/g" vendir.yml
  ! diff vendir.yml vendir.yml.orig
  rm vendir.yml.orig
  git add vendir.yml
  git commit -m "Initial branch creation for k8s version $v"
  git push --set-upstream origin "$BRANCH_NAME" $PUSH_OPTIONS
  git co master
done
