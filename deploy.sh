#!/bin/bash

if [[ -z $PUBLIC_REPO ]]; then
  echo "[CD] No public repository set, exiting deploy"
  exit 0
fi

if [[ ! $PUBLIC_REPO =~ ^git@.+:.+\/.+\.git$ ]]; then
  echo "[CD] Public repository needs to be an ssh url"
  exit 1
fi

echo "[CD] Add Remote"
git remote add public $PUBLIC_REPO
git fetch public

echo "[CD] Create New Release Branch"
# If the remote master exists, check it out
# otherwise just use the tag to start with
if [[ $(git branch -a | grep public/master) ]]; then
  git checkout public/master
fi

git checkout -b release

echo "[CD] Merge the Tag"
git merge --strategy-option theirs --squash $TRAVIS_TAG --allow-unrelated-histories

echo "[CD] Remove non-release items"
git rm -rf test
git rm -f .travis.yml
git rm -f .gitignore
git rm -f go.*
git rm -f "$0"

echo "[CD] Commit"
git commit -m "$TRAVIS_TAG release"

# Reset the root if new repository
if [[ ! $(git branch -a | grep public/master) ]]; then
  git reset $(git commit-tree HEAD^{tree} -m "$TRAVIS_TAG release")
fi

echo "[CD] Push to Remote Master"
git push public release:master

echo "[CD] Make Public Tag"
git tag -d $TRAVIS_TAG
git tag $TRAVIS_TAG
git push public $TRAVIS_TAG

echo "[CD] Done"
