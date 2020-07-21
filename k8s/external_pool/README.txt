This directory contains a helm chart for creating HTCondor worker nodes,
that can connect to an external HTCondor pool using password (shared secret) authentication.
(see bare_metal/submit_ubuntu for an example)

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

Required secrets
================

In order for the htcondor-wn to be able to connect to the external pool's collector,
you need to create a secret in the target namespace.

The default secret name is 
htcondor-secret
, but you can change it in 
prp-htcondor-wn/values.yaml

The secret must contain a key named
pool_password

The easiest way to create such a secret is by copying the condor pool secret file
(which can be found with `condor_config_val SEC_PASSWORD_FILE`)
into a local file named
pool_password

and then propagate it into Kuberenetes with
kubectl create secret generic -n ${YOUR_NAMESPACE} htcondor-secret --from-file=pool_password 

