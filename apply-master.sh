#!/bin/bash
REPOSITORY=git://github.com/winebarrel/ridgepole-example.git
git clone --branch=master $REPOSITORY master
cd master
bundle exec rake development:apply[blog]
cd ..
rm -rf master
