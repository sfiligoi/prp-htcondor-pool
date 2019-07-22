#!/bin/bash

if [ $# -ne 2 ]; then
  echo "ERROR: Missing arguments"
  echo "Usage:"
  echo "  add-prp-wn-gpu.sh <shortname> <imagename>"
  echo "e.g."
  echo "  add-prp-wn-gpu.sh tf tensorflow/tensorflow:latest-gpu-py3"
  exit 2
fi

shortid="$1"
imagename="$2"

raw_dirname=`dirname $0`
abs_dirname=`(cd ${raw_dirname} && pwd)`

rnd=`date +%s`
rnd13=${rnd}

tmpname=/tmp/uaf-startd-${shortid}-gpu-${rnd13}.yaml

sed -e "s/XXXX/${rnd13}/" -e "s/IiIi/${shortid}/" -e "s#IIII#${imagename}#" ${abs_dirname}/uaf-startd-gpu.template.yaml > ${tmpname}

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to create ${tmpname}"
  exit 1
fi

kubectl create -f ${tmpname}

rm -f ${tmpname}

