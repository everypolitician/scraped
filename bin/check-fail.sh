#!/bin/bash
#
# Checks tests introduced in pull requests fail on master.

set -eo pipefail

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  echo "Skipping $0 for non-PR build"
  exit 0
fi

if echo "${TRAVIS_PULL_REQUEST_BRANCH}" | grep -qi refactor; then
  echo "The title of the PR indicates this is a refactoring; skipping this check"
  exit 0
fi

target_branch="${TRAVIS_BRANCH}"

if [ -z "${target_branch}" ]; then
  echo "No target branch found" >&2
  exit 1
fi

# Checkout the branch that the pull request is targeting...
git checkout "${target_branch}"

# ...but revert the test code back to the pull request version
for dir in t tests test spec; do
  git checkout "HEAD@{1}" -- "${dir}" 2> /dev/null || true
done

if bundle exec rake test; then
  echo "Your newly introduced tests should have failed on ${target_branch}" >&2
  echo "If you expected them to pass then include 'refactor' in the branch name" >&2
  exit 1
else
  echo "Your new tests failed on ${target_branch}, which is a good thing!"
fi
