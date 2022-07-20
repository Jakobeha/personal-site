#!/bin/bash

# Modified from https://jaspervdj.be/hakyll/tutorials/github-pages-tutorial.html

# Verify correct branch
git checkout main

# Build source
./build.sh

# Clone repo into dist temporarily
DIR=$(pwd)
function cleanup {
  rm -rf "$DIR/dist/.git"
}
trap cleanup EXIT
cp -r .git "dist/"

# Move to dist, checkout gh-pages branch with old commits
cd "dist"
git checkout -b gh-pages
git fetch
git reset origin/gh-pages
IS_FIRST=$?

# Commit and push new changes
git add -A
if [ $IS_FIRST -eq 0 ]; then
  git commit -m "publish"
else
  git commit -m "publish (initial)"
fi
git push origin gh-pages
