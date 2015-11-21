#!/bin/sh

bundle exec jekyll build

LAST_COMMIT="$(git rev-list --format=%B --max-count=1 HEAD)"

pushd `pwd`

cd /tmp
rm -rf /tmp/olegantonyan.github.io
git clone git@github.com:olegantonyan/olegantonyan.github.io.git
cd olegantonyan.github.io && rm -rf ./*

popd

cp -R ./_site/* /tmp/olegantonyan.github.io

pushd `pwd`

cd /tmp/olegantonyan.github.io
git add . --all
git commit -am $LAST_COMMIT
git push

popd
