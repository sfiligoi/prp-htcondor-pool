#!/bin/bash

raw_dirname=`dirname $0`
abs_dirname=`(cd ${raw_dirname} && pwd)`

rnd=`date +%s`
rnd13=${rnd}

tmpname=/tmp/uaf-startd-tf-gpu-${rnd13}.yaml

sed "s/XXXX/${rnd13}/" ${abs_dirname}/uaf-startd-tf-gpu.template.yaml > ${tmpname}

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to create ${tmpname}"
  exit 1
fi

kubectl create -f ${tmpname}

rm -f ${tmpname}

