#!/usr/bin/env bash
#
# Shell script to create a Dockerfile from a template, populating certain key
# values, and to then build a Docker image. Requires that you are already
# logged in to Docker Hub.
#

if [ ! -f Dockerfile ]; then
  echo "Error: must invoke from the top level of the cloned directory"
  exit 1
fi

rootname="newrelic"
if [ $# -ne 0 ]
  then
rootname=$1
fi


#Retrieve the latest nrsysmond binary
wget -r -l1 --no-parent -A -linux.tar.gz http://download.newrelic.com/server_monitor/release/

#Extract the tar file
tar -xvzf download.newrelic.com/server_monitor/release/*-linux.tar.gz

#Copy the 64-bit nrsysmond binary to the Dockerfile folder
cp newrelic-sysmond-*-linux/daemon/nrsysmond.x64 .

#Parse version number from the file name
input=`ls download.newrelic.com/server_monitor/release/*-linux.tar.gz`
export NRSYSMONDVERSION=`echo $input| cut -d'-' -f 3`

#Build the docker image
ID=$(docker build -t ${rootname}/nrsysmond:${NRSYSMONDVERSION} .)

#Tag the image
docker tag --force=true ${rootname}/nrsysmond:${NRSYSMONDVERSION}  ${rootname}/nrsysmond:latest

#Cleanup temporary files
rm -r download.newrelic.com
rm -r newrelic-sysmond-*-linux
rm nrsysmond.x64
