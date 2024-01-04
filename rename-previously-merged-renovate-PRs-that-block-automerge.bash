#!/bin/bash

set -x
set -f # disable file name expansion, especially in for loops

LIMIT="300"

echo "Renaming renovate PRs that were merged before the branch was reset and forced pushed"
PRS=$(gh pr list \
  --limit ${LIMIT} \
  --app "renovate" \
  --repo orange-cloudfoundry/k3s-packages-boshrelease \
  --search "is:merged" \
  --json number \
  | jq -r '.[].number' )
echo "first PRs (maxed at ${LIMIT}} to rename are: ${PRS}"
for p in $PRS; do
  gh --repo orange-cloudfoundry/k3s-packages-boshrelease pr edit $p --title "merged renovate PR $p onto a branch forced pushed. renamed to not block new automerges"
  gh --repo orange-cloudfoundry/k3s-packages-boshrelease pr comment $p --body "through rename-previously-merged-renovate-PRs-that-block-automerge.bash: this PR was likely blocking automerge, see https://github.com/orange-cloudfoundry/k3s-packages-boshrelease/pull/52#issuecomment-1876989204 for diagnostics steps"
done;

echo "please rerun this command to check not more PR beyond $LIMIT is left to process"