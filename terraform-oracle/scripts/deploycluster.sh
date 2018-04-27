#!/bin/bash

#Setup Passwordless SSH
ssh-keygen -q -N '' -f ~/.ssh/id_rsa

echo $1 > test.pem

chmod 600 test.pem
 
for HOST in $(cat hosts); do cat ~/.ssh/id_rsa.pub | ssh -i test.pem $2@$HOST  'cat >> ~/.ssh/authorized_keys'; done

rm -f test.pem

cd $3

./bin/alluxio bootstrapConf $4
./bin/alluxio copyDir conf

./bin/alluxio format
./bin/alluxio-start.sh all SudoMount
./bin/alluxio runTests