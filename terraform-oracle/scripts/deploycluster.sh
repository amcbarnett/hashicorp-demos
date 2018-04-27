#!/bin/bash

#Setup Passwordless SSH
ssh-keygen -q -N '' -f ~/.ssh/id_rsa

for HOST in $(cat hosts); do cat ~/.ssh/id_rsa.pub | ssh -i $1 $2@$HOST  'cat >> ~/.ssh/authorized_keys'; done

cd $3

./bin/alluxio bootstrapConf $4
./bin/alluxio copyDir conf

./bin/alluxio format
./bin/alluxio-start.sh all SudoMount
./bin/alluxio runTests