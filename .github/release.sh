#!/bin/sh

SITE_REPO_NAME="undefined-reference"
PAGES_BRANCH="gh-pages"

bundle exec jekyll build

LAST_COMMIT="$(git rev-list --format=%B --max-count=1 HEAD)"
pushd `pwd`
cd /tmp
rm -rf /tmp/$SITE_REPO_NAME
git clone -b $PAGES_BRANCH git@github.com:olegantonyan/$SITE_REPO_NAME.git
cd $SITE_REPO_NAME && rm -rf ./*
popd

cp -R ./_site/* /tmp/$SITE_REPO_NAME

pushd `pwd`
cd /tmp/$SITE_REPO_NAME
git add . --all
git commit -m "$LAST_COMMIT"
git push
popd
