#!/bin/bash

echo ${git_user}
if [[ $TRAVIS_BRANCH == 'master' ]] ; then
  cd _site
  git init

  echo ${git_user}

  git config user.name "Travis CI"
  git config user.email "oleg.b.antonyan@gmail.com"

  git add .
  git commit -m "Deploy"

  # We redirect any output to
  # /dev/null to hide any sensitive credential data that might otherwise be exposed.
  git push --force --quiet "https://${git_user}:${git_password}@${git_target}" master:master > /dev/null 2>&1
else
  echo 'Invalid branch. You can only deploy from gh-pages.'
  exit 1
fi
