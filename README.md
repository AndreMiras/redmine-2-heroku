Redmine 2 Heroku
===================

This is a build script and patches for deploying Redmine 2 on Heroku.

You must have a Redmine dependencies already set up on your host (for running bundle install).

1. Edit `redmine-2-heroku.sh` and change the variables at the top to match your environment.
2. Run `redmine-2-heroku.sh`. This will download Redmine, patch it and deploy it on Heroku.

Credits
-------

* [HowTo Install Redmine on Heroku](http://www.redmine.org/projects/redmine/wiki/HowTo_Install_Redmine_(%3E_25x)_on_Heroku)
