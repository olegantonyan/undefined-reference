#!/bin/sh

SITE_REPO_NAME="undefined-reference"
PAGES_BRANCH="gh-pages"

check_revision()
{
  git diff --exit-code
  RESULT="$?"
  if [ "$RESULT" != "0" ]; then
    >&2 echo "WARNING: Working directory contains unstaged files."
    exit 1
  fi
  REV_LOCAL="$(git rev-parse HEAD)"
  REV_REMOTE="$(git rev-parse origin/master)"
  if [ "$REV_LOCAL" != "$REV_REMOTE" ]; then
    >&2 echo "WARNING: HEAD is not the same as origin/master. Run git push to sync changes."
    exit 1
  fi
}

git add . --all && git commit && git push

check_revision
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
