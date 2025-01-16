#!/usr/bin/env bash

if ! gh --version >/dev/null 2>&1;then
  echo "Please download and install gh cli https://github.com/cli/cli/releases/"
  exit 1
fi

gh --version
gh repo set-default orange-cloudfoundry/k3s-packages-boshrelease

for branch in $(git --no-pager branch -r|grep -E "/release-[0-9.]*$");do
  echo "Processing $branch"
  release=$(echo $branch|cut -d'/' -f2)
  branch_head_ref=$(echo $branch|sed "s@/@:@g")
  if [ "$(gh label list --search "target/"|grep "target/$release"|wc -l)" -eq 0 ];then
    echo "Creating label target/$release"
    gh label create "target/$release" --color 0020CC
  fi
  echo "gh pr create --base master -t \"$release\" -b \"We use this PR to track changes related to K8S $release\" -l \"target/$release\" -l k3s-base --head $release"
  # We ignore PR creation errors
  gh pr create --base master -t "$release" -b "We use this PR to track changes related to K8S $release" -l "target/$release" -l k3s-base --head $release
done

gh pr list -l k3s-base