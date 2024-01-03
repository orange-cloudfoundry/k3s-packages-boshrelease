#!/bin/bash
#set -x
#set -e # exit on non-zero status

# This script creates new release branches for all available release branches in k3s-io/k3s repo starting from current version in vendir.yml from master branch.
#
# When PUSH_OPTIONS=true, it also recreates all existing release branches from master branch

PUSH_OPTIONS=""
if [ "$FORCE_PUSH" = "true" ] ;then
  PUSH_OPTIONS="$PUSH_OPTIONS --force"
fi
current_version=$(yq -r '.directories[0].contents[] | select (.path=="k3s-io/k3s") | .githubRelease.tag ' ./vendir.yml)
current_version=${current_version#v}
MIN_VERSION=$(echo "$current_version"|cut -d'.' -f1-2)

function listK3sRepoBranches() {
  git ls-remote -h https://github.com/k3s-io/k3s "release-*" | sed 's/refs\/heads\///' | awk '{print $2}'
}

for ref in $(listK3sRepoBranches) ; do
  v=${ref#release-}
  BRANCH_NAME="${ref}"
  echo "Extracted values - v: $v - BRANCH_NAME: $BRANCH_NAME"
  if [ $(echo "$v <= $MIN_VERSION"|bc) -eq 1 ];then
    echo "Skipping version $v"
    continue
  else
    echo "Keeping $v as $v > $MIN_VERSION"
  fi
  if [ "$FORCE_PUSH" = "true" ] ;then
    git branch -d "$BRANCH_NAME"
  fi
  git co -b "$BRANCH_NAME"
  sed -i.orig "s/tag: v.*/tag: v${v}.0/g" vendir.yml
  diff vendir.yml vendir.yml.orig
  rm vendir.yml.orig
  git add vendir.yml
  git commit -m "Initial branch creation for k8s version $v"
  git push --set-upstream origin "$BRANCH_NAME" $PUSH_OPTIONS
  git co master
done

git branch
