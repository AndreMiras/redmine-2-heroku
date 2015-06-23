#!/bin/bash

# leave blank if you want "heroku create" to pick up one for you
HEROKU_PROJECT=""
REDMINE_VERSION="2.3.1"
ARCHIVE_NAME="redmine-$REDMINE_VERSION.tar.gz"
DOWNLOAD_URL="http://www.redmine.org/releases/$ARCHIVE_NAME"
SOURCE_DIR="redmine-$REDMINE_VERSION/"

# Download Redmine and extract it
wget -c $DOWNLOAD_URL
tar -xvzf $ARCHIVE_NAME
cd $SOURCE_DIR

# Start tracking changes
git init
git add -A
git commit -a -m "initial commit fresh Redmine $REDMINE_VERSION download"

# Patch for Heroku
patch -p1 --input ../files/redmine-2-heroku.patch

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
