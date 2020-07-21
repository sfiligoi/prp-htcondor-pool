This directory contains a helm chart for creating HTCondor worker nodes.

You will probably want to edit 
prp-htcondor-wn/values.yaml
and change
  htcondor.collector 
  k8s.namespace
defaults.

Furthermore, all the values can be changed at runtime, by passing them to helm.

For example:
helm install prp-htcondor-wn --generate-name \
  --set resources.cpus=2 --set resources.memMBs=8000 --set resources.gpus=1 \
  --set image.repository=nvidia/cuda:10.0-runtime-centos7

