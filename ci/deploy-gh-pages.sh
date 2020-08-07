#!/usr/bin/env bash
#
# Push HTML pages to the gh-pages branch of the current Github repository.
#

# To return a failure if any commands inside fail
set -e
set -x

REPO=$TRAVIS_REPO_SLUG
BRANCH=gh-pages
CLONE_DIR=deploy
CLONE_ARGS="--quiet --branch=$BRANCH --single-branch"
REPO_URL=https://${GH_TOKEN}@github.com/${REPO}.git
HTML_SRC=${TRAVIS_BUILD_DIR}/${HTML_BUILDDIR:-doc/_build/html}
# Place the HTML in different folders for different versions
VERSION=${GMT_DOC_VERSION}

echo -e "DEPLOYING HTML TO GITHUB PAGES:"
echo -e "Target: branch ${BRANCH} of ${REPO}"
echo -e "HTML source: ${HTML_SRC}"
echo -e "HTML destination: ${VERSION}"

# Clone the project, using the secret token.
# Uses /dev/null to avoid leaking decrypted key.
echo -e "Cloning ${REPO}"
git clone ${CLONE_ARGS} ${REPO_URL} ${CLONE_DIR} 2>&1 >/dev/null

cd ${CLONE_DIR}

# Configure git to a dummy Travis user
git config user.email "travis@nothing.com"
git config user.name "TravisCI"

# Delete all the files and replace with our new set
echo -e "Remove old files from previous builds"
rm -rf ${VERSION}
cp -Rf ${HTML_SRC}/ ${VERSION}/
rm -f latest
ln -sf ${VERSION} latest

# Need to have this file so that Github doesn't try to run Jekyll
touch .nojekyll

echo -e "Add and commit changes"
git add -A .
git status
git commit --amend --no-edit

echo -e "Pushing to GitHub..."
git push -fq origin $BRANCH 2>&1 >/dev/null

# Workaround for https://github.com/travis-ci/travis-ci/issues/6522
# Turn off exit on failure.
set +x
set +e
