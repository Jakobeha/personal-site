#!/bin/bash

# Modified from https://jaspervdj.be/hakyll/tutorials/github-pages-tutorial.html

# Verify correct branch
git checkout develop

# Build source
./build.sh

# Clone repo into dist temporarily
DIR=$(pwd)
function cleanup {
  rm -rf "$DIR/dist/.git"
}
trap cleanup EXIT
cp -r .git "dist/"

# Move to dist, checkout site branch with old commits
cd "dist"
git checkout -b site
git fetch
git reset origin/site
IS_FIRST=$?

# Commit and push new changes
git add -A
if [ $IS_FIRST -eq 0 ]; then
  git commit -m "publish (develop branch has the code)"
else
  git commit -m "publish initial (develop branch has the code)"
fi
git push origin site
