#!/bin/bash
set -x
set -e # exit on non-zero status

for v in 1.25 1.26 1.27 1.28 1.29 1.30 1.31 ; do
  BRANCH_NAME="release-${v}"
  git co -b $BRANCH_NAME ||
    git co $BRANCH_NAME
  sed -i.orig "s/tag: v.*/tag: v${v}.0/g" vendir.yml
  ! diff vendir.yml vendir.yml.orig
  rm vendir.yml.orig
  git add vendir.yml
  git commit -m "set up release for version $v"
  git push --set-upstream origin $BRANCH_NAME --force
  ! gh pr create --base master --repo orange-cloudfoundry/k3s-packages-boshrelease --fill --body "Track divergence of release branches with master"
  git co master
done
