# HTCondor Pool in Kubernetes

## Overview

This repo contains all the necessary bits and pieces to create a HTCondor pool in Kubernetes.
For more information about HTCondor, look at the [HTCondor home page](https://research.cs.wisc.edu/htcondor/).

The setups have been tested in the [PRP Nautilus Kubernetes cluster](http://pacificresearchplatform.org/nautilus/)
but are expected to work in other Kubernetes setups, too.

## Complete HTCondor pool

The most complete setup in here is the one that creates a complete HTCondor in Kubernetes.

More details in [k8s/tensor_pool](k8s/tensor_pool).

## Other setup

All the other setups are either experiemental or geared toward specific use cases in our environemnt.
Feel free to browse through them, but be aware they are not meant to be generic.

