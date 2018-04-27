#!/bin/bash

cd $1

./bin/alluxio bootstrapConf $2
cp conf/alluxio-site.properties.template cond/alluxio-site.properties
./bin/alluxio copyDir conf

./bin/alluxio format
./bin/alluxio-start.sh all SudoMount

#sleep 15s
#./bin/alluxio runTests