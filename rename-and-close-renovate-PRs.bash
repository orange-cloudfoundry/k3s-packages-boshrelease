#!/bin/bash

set -x
set -f # disable file name expansion, especially in for loops

LIMIT="300"

echo "Renaming and closing PRs to get them recreated by renovate"
echo "learn more at https://github.com/renovatebot/renovate/discussions/13975#discussioncomment-2104370"
PRS=$(gh pr list \
  --limit ${LIMIT} \
  --app "renovate" \
  --repo orange-cloudfoundry/k3s-packages-boshrelease \
  --json number \
  | jq -r '.[].number' )
echo "first PRs (maxed at ${LIMIT}} to rename are: ${PRS}"
for p in $PRS; do
  gh --repo orange-cloudfoundry/k3s-packages-boshrelease pr edit $p --title "PR $p renamed to be closed and recreated by renovate"
  gh --repo orange-cloudfoundry/k3s-packages-boshrelease pr comment $p --body "through rename-and-close-renovate-PRs.bash script: renamed and closed and recreated by renovate, learn more at https://github.com/renovatebot/renovate/discussions/13975#discussioncomment-2104370 "
  gh --repo orange-cloudfoundry/k3s-packages-boshrelease pr close $p --delete-branch
done;

echo "please rerun this command to check not more PR beyond $LIMIT is left to process"