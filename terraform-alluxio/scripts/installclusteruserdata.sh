#!/bin/bash

sudo yum install -y java-1.8.0-openjdk-devel

curl -Ls http://downloads.alluxio.org/downloads/files/1.7.1/alluxio-1.7.1-hadoop-2.8-bin.tar.gz | tar -xz 

mv alluxio-1.7.1-hadoop-2.8 ${cluster_name}