#!/bin/sh

set -e

if [ "$TRAVIS_PULL_REQUEST" = false ]
then
  echo "Skipping $0 for non-PR build"
  exit 0
fi

TARGET_BRANCH="$TRAVIS_BRANCH"
if echo "$TRAVIS_PULL_REQUEST_BRANCH" | grep -qi refactor
then
    echo "The title of the PR indicates this is a refactoring; skipping this check"
    exit 0
fi

if [ x"$TARGET_BRANCH" = x ]
then
    echo "No target branch found"
    exit 1
fi

git checkout "$TARGET_BRANCH"

for d in t tests test spec
do
    git checkout HEAD@{1} -- $d 2> /dev/null || true
done

if bundle exec rake test
then
    echo "Your newly introduced tests should have failed on $TARGET_BRANCH"
    echo "If you expected them to pass then include 'refactor' in the branch name"
    exit 1
else
    echo "Your new tests failed on $TARGET_BRANCH, which is a good thing!"
fi
