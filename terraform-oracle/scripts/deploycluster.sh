#!/bin/bash

cd $1

./bin/alluxio bootstrapConf $2
./bin/alluxio copyDir conf

./bin/alluxio format
./bin/alluxio-start.sh all SudoMount
./bin/alluxio runTests