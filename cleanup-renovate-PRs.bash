#!/usr/bin/env bash

if ! gh --version >/dev/null 2>&1;then
  echo "Please download and install gh cli https://github.com/cli/cli/releases/"
  exit 1
fi

gh --version
gh repo set-default orange-cloudfoundry/k3s-packages-boshrelease

echo "list renovate open PRs"
gh pr list --app renovate --state open --json number,title --jq '.[]?|select(.title|endswith("- abandoned")) | "#" + (.number|tostring) + " -#- " + .title'|more

echo "closing abandoned PRs"
gh pr list --app renovate --state open --json number,title --jq '.[]?|select(.title|endswith("- abandoned")) | .number'|xargs -I {} gh pr close {} --comment "auto closing abandonned PR"
