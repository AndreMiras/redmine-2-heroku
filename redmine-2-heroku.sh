#!/bin/bash

# leave blank if you want "heroku create" to pick up one for you
HEROKU_PROJECT=""
REDMINE_VERSION="2.6.5"
ARCHIVE_NAME="redmine-$REDMINE_VERSION.tar.gz"
DOWNLOAD_URL="http://www.redmine.org/releases/$ARCHIVE_NAME"
SOURCE_DIR="redmine-$REDMINE_VERSION/"


version_lte() {
    # "sort -V" is available on coreutils-7
    [  "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

version_lt() {
    [ "$1" = "$2" ] && return 1 || version_lte $1 $2
}

# Download Redmine and extract it
wget -c $DOWNLOAD_URL
rm -rf $SOURCE_DIR
tar -xvzf $ARCHIVE_NAME
cd $SOURCE_DIR

# Start tracking changes
git init
git add -A
git commit -a -m "initial commit fresh Redmine $REDMINE_VERSION download"

# Patch for Heroku
patch -p1 --input ../files/redmine-2.3-allow-vendor-plugin.patch
patch -p1 --input ../files/redmine-2.3-assets-precompile.patch
if version_lt $REDMINE_VERSION 2.6.5
then
    patch -p1 --input ../files/redmine-2.3-database-gemfile.patch
    patch -p1 --input ../files/redmine-2.3-gitignore.patch
else
    patch -p1 --input ../files/redmine-2.6.5-database-gemfile.patch
    patch -p1 --input ../files/redmine-2.6.5-gitignore.patch
fi

# Install gems
bundle install
bundle exec rake generate_secret_token

# Deploy on Heroku
if [[ -z "$HEROKU_PROJECT" ]]
then
    heroku create
else
    # this will fail if this name is already taken
    # but, next command will success if you own the application
    heroku create $HEROKU_PROJECT
    # shortcut for:
    # git remote add heroku git@heroku.com:project.git
    heroku git:remote -a $HEROKU_PROJECT
fi
git add -A
git commit -m "patch for Heroku"
git push heroku master
heroku run rake db:migrate
heroku run REDMINE_LANG=en rake redmine:load_default_data
heroku info
heroku open
