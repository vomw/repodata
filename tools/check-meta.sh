#!/bin/bash
set -euo pipefail

set -o errexit
set -o nounset
set -o pipefail

git fetch origin $CI_REPO_DEFAULT_BRANCH

check_target="HEAD" # always HEAD, but needed for local debuggung

deleted=("$(git diff --name-only --diff-filter=D $check_target $CI_REPO_DEFAULT_BRANCH | sed -n 's,metadata/\([^/]*\.yml\),\1,p')")
added=("$(git diff --name-only --diff-filter=A $check_target $CI_REPO_DEFAULT_BRANCH | sed -n 's,metadata/\([^/]*\.yml\),\1,p')")

global_error=false

# Check deleted apps
if [[ -n "${deleted[*]}" ]]; then
  for app in ${deleted[@]}; do
      appid="$(basename "$app" .yml)"
      echo "Checking removal of $appid"
      if [ -d "${CI_WORKSPACE}/metadata/${appid}" ]; then
        echo "✗ metadata folder was not removed"
        global_error=true
      fi
  done
else
  echo "✓ No deleted apps"
fi

# Check added apps
if [[ -n "${added[*]}" ]]; then
  for app in ${added[@]}; do
      appid="$(basename "$app" .yml)"
      echo "Checking addition of $appid"
  done
else
  echo "✓ No added apps"
fi

if $global_error; then
  echo "There were errors, please check above log"
  exit 1
fi