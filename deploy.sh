#!/bin/sh

bundle exec jekyll build

pushd `pwd`

cd /tmp
git clone git@github.com:olegantonyan/olegantonyan.github.io.git
cd olegantonyan.github.io && rm -rf ./*

popd

cp -R ./_site/* /tmp/olegantonyan.github.io

pushd `pwd`

cd /tmp/olegantonyan.github.io
git add . --all
git commit -am 'update'
git push

popd



