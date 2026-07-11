#!/bin/bash
# SPDX-FileCopyrightText: 2026 IzzyOnDroid Team
# SPDX-License-Identifier: AGPL-3.0-or-later

set -euo pipefail

does_file_exist (){
  return_code="$(curl -s -L -o /dev/null -w '%{http_code}' "$1" | cut -c1-1)"
  if [[ "$return_code" = "2" ]]; then
    exists=true
  else
    exists=false
  fi
}

CI_REPO_DEFAULT_BRANCH="${CI_REPO_DEFAULT_BRANCH:-main}"
git fetch origin $CI_REPO_DEFAULT_BRANCH

check_target="${CHECK_TARGET:-HEAD}"

deleted=("$(git diff --name-only --diff-filter=D origin/$CI_REPO_DEFAULT_BRANCH $check_target | sed -n 's,metadata/\([^/]*\.yml\),\1,p')")
changed=("$(git diff --name-only --diff-filter=AM origin/$CI_REPO_DEFAULT_BRANCH $check_target | sed -n 's,metadata/\([^/]*\.yml\),\1,p')")

global_error=false

# Check deleted apps
if [[ -n "${deleted[*]}" ]]; then
  for app in ${deleted[@]}; do
      app_succeeded=true
      appid="$(basename "$app" .yml)"
      echo "? Checking removal of $appid"

      # check if metadata folder was removed
      if [ -d "${CI_WORKSPACE:-.}/metadata/${appid}" ]; then
        echo "    ✗ metadata folder was not removed"
        global_error=true
        app_succeeded=false
      fi

      if $app_succeeded; then
        echo "  ✓ no errors found"
      fi
  done
else
  echo "✓ No deleted apps"
fi

# Check added/changed apps
if [[ -n "${changed[*]}" ]]; then
  for app in ${changed[@]}; do
      app_succeeded=true
      appid="$(basename "$app" .yml)"
      echo "? Checking addition/modification of $appid"

      metadata_file="${CI_WORKSPACE:-.}/metadata/${app}"

      fastlane_url="$(cat "$metadata_file" | yq -r '.MaintainerNotes.Fastlane')"
      fastlane_features="$(cat "$metadata_file" | yq -r '.MaintainerNotes.FastlaneFeatures')"
      allowed_signing_keys="$(cat "$metadata_file" | yq -r '.AllowedAPKSigningKeys')"

      # check if MaintainerNotes.Fastlane exists
      if [[ "$fastlane_url" = "null" ]]; then
        echo "    ✗ $app contains no Fastlane URL"
        global_error=true
        app_succeeded=false
      else
        # check if minimal file set exists
        url="$fastlane_url/en-US/short_description.txt"
        does_file_exist "$url"
        if [ $exists = false ]; then
          echo "    ✗ Fastlane for $app contains no /en-US/short_description.txt ($url)"
          global_error=true
          app_succeeded=false
        fi

        url="$fastlane_url/en-US/full_description.txt"
        does_file_exist "$url"
        if [ $exists = false ]; then
          echo "    ✗ Fastlane for $app contains no /en-US/full_description.txt ($url)"
          global_error=true
          app_succeeded=false
        fi

        url="$fastlane_url/en-US/images/icon.png"
        does_file_exist "$url"
        if [ $exists = false ]; then
          echo "    ✗ Fastlane for $app contains no /en-US/images/icon.png ($url)"
          global_error=true
          app_succeeded=false
        fi
      fi

      # check if MaintainerNotes.FastlaneFeatures exist
      if [[ "$fastlane_features" = "null" ]]; then
        echo "    ✗ $app has no FastlaneFeatures defined"
        global_error=true
        app_succeeded=false
      else
        # check if we have at least shortdesc,fulldesc,icon
        min_features="$(echo "$fastlane_features" | sed -rn 's/.*shortdesc,fulldesc(MD|NL)?,(.*,)?icon.*/found/p')" # note that this also assumes the "correct order" of elements. Might be better to split into an array, and check elements
        if [[ "$min_features" != "found" ]]; then
          echo "    ✗ $app lacks minimum fastlane features (shortdesc,fulldesc*,icon)! Set is: '${fastlane_features}'!"
          global_error=true
          app_succeeded=false
        fi
      fi

      # check if AllowedAPKSigningKeys exists
      if [[ "$allowed_signing_keys" = "null" ]]; then
        echo "    ✗ $app contains no AllowedAPKSigningKeys"
        global_error=true
        app_succeeded=false
      fi

      if $app_succeeded; then
        echo "  ✓ no errors for $appid found"
      fi
  done
else
  echo "✓ No added/changed apps"
fi

if $global_error; then
  echo "There were errors, please check above log"
  exit 1
fi