#!/bin/sh

SITE_REPO_NAME="undefined-reference"
PAGES_BRANCH="gh-pages"


echo "running jekyll build"
bundle exec jekyll build

LAST_COMMIT="$(git rev-list --format=%B --max-count=1 HEAD)"
echo "last commit: $LAST_COMMIT"
echo "cloning $PAGES_BRANCH branch"
pushd `pwd`
cd /tmp
rm -rf /tmp/$SITE_REPO_NAME
git clone -b $PAGES_BRANCH git@github.com:olegantonyan/$SITE_REPO_NAME.git
cd $SITE_REPO_NAME && rm -rf ./*
popd

echo "copying built artifacts to tem directory"
cp -R ./_site/* /tmp/$SITE_REPO_NAME

echo "pushing build artifacts to $PAGES_BRANCH branch"
pushd `pwd`
cd /tmp/$SITE_REPO_NAME
git add . --all
git commit -m "$LAST_COMMIT"
git push
popd
