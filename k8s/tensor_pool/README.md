# HTCondor Pool in Kubernetes

## Overview

The YAML file in this directory is a ready-to-use example for creating a private HTCondor pool in Kubernetes.
For more information about HTCondor, look at the [HTCondor home page](https://research.cs.wisc.edu/htcondor/).

Note that the example YAML sets up worker nodes that are based on the GPU version of tensorflow,
but that can be changed to virtually any other image, including user-generated ones.
The only restriction is that they are based on either CentOS 7 or Ubuntu 16/18 (or similar). 

## Starting the HTCondor pool

First, create a plain text password file.
Any hard-to-guess string will do.

e.g.
```
echo "BlahSecretBlah" > poolpasswd
```

Then store that information into a Kubernetes secret named **condor-poolpasswd**:
```
kubectl create secret generic condor-poolpassswd -n YOUR_NAMESPACE --from-file=poolpasswd
```

You are now ready to deploy the HTCondor pool, by creating creating the resources using the yaml file:
```
kubectl create -n YOUR_NAMESPACE -f tensor-pool.yaml
```

And unless there are problems with finding the required resources, you now have the HTCOndor pool up and running.

You should see something like this:
```
$ kubectl get service -n YOUR_NAMESPACE
NAME          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
condor-head   ClusterIP   None         <none>        9618/TCP   2m
$ kubectl get StatefulSet -n YOUR_NAMESPACE
NAME            READY   AGE
condor-head     1/1     2m
tensor-submit   1/1     2m
$ kubectl get Deployment -n YOUR_NAMESPACE
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
tensor-wn   3/3     3            3           2m
```

## Using the HTCondor pool

The HTCondor submit node is called **tensor-submit-0**. 

You can use the Kuberenetes exec functionality to log into it. 


For example:
```
$ kubectl exec -it tensor-submit-0  -n YOUR_NAMESPACE -- /bin/bash

________                               _______________                
___  __/__________________________________  ____/__  /________      __
__  /  _  _ \_  __ \_  ___/  __ \_  ___/_  /_   __  /_  __ \_ | /| / /
_  /   /  __/  / / /(__  )/ /_/ /  /   _  __/   _  / / /_/ /_ |/ |/ / 
/_/    \___//_/ /_//____/ \____//_/    /_/      /_/  \____/____/|__/


WARNING: You are running this container as root, which can cause new files in
mounted volumes to be created as the root user on your host machine.

To avoid this, run the container by specifying your user's userid:

$ docker run -u $(id -u):$(id -g) args...

Please use user user1 for job submission
 su - user1
root@tensor-submit-0:/#  su - user1

________                               _______________                
___  __/__________________________________  ____/__  /________      __
__  /  _  _ \_  __ \_  ___/  __ \_  ___/_  /_   __  /_  __ \_ | /| / /
_  /   /  __/  / / /(__  )/ /_/ /  /   _  __/   _  / / /_/ /_ |/ |/ / 
/_/    \___//_/ /_//____/ \____//_/    /_/      /_/  \____/____/|__/


You are running this container as user with ID 1001 and group 1001,
which should map to the ID and group for your user on the Docker host. Great!

user1@tensor-submit-0:~$ 
```

Once inside, use the usual HTCondor commands.

For example:
```
user1@tensor-submit-0:~$ condor_status
Name                                     OpSys      Arch   State     Activity LoadAv Mem     ActvtyTime

tensor-wn-7bd54b548f-bd2mh.cluster.local LINUX      X86_64 Unclaimed Idle      0.000  32042  0+00:00:03
tensor-wn-7bd54b548f-hfgrq.cluster.local LINUX      X86_64 Unclaimed Idle      0.000 192086  0+00:00:03
tensor-wn-7bd54b548f-lsdlk.cluster.local LINUX      X86_64 Unclaimed Idle      0.000 257824  0+00:09:42

               Total Owner Claimed Unclaimed Matched Preempting Backfill  Drain

  X86_64/LINUX     3     0       0         3       0          0        0      0

         Total     3     0       0         3       0          0        0      0
user1@tensor-submit-0:~$ condor_q


-- Schedd: tensor-submit-0.cluster.local : <10.244.11.20:9618?... @ 07/31/19 18:39:11
OWNER BATCH_NAME      SUBMITTED   DONE   RUN    IDLE   HOLD  TOTAL JOB_IDS

Total for query: 0 jobs; 0 completed, 0 removed, 0 idle, 0 running, 0 held, 0 suspended 
Total for user1: 0 jobs; 0 completed, 0 removed, 0 idle, 0 running, 0 held, 0 suspended 
Total for all users: 0 jobs; 0 completed, 0 removed, 0 idle, 0 running, 0 held, 0 suspended

user1@tensor-submit-0:~$ 
```

### Testing the setup

Here is a simple example workflow to test the setup (note that your output may be slightly different):

```
user1@tensor-submit-0:~$ cat >mymul.py <<EOF 
#!/usr/local/bin/python

import socket
print("Running on %s"%socket.gethostname())

# simple example to show the matrix multiplication with tensorflow                                                                                                            

import tensorflow as tf
matrix1 = tf.random_normal([8, 8], mean=-1, stddev=4)
matrix2 = tf.matrix_inverse(matrix1)
product = tf.matmul(matrix1, matrix2)
with tf.Session() as sess:
    result = sess.run(product)
    print("result of matrix multiplication")
    print("===============================")
    print(result)
    print("===============================")

EOF
user1@tensor-submit-0:~$ chmod a+x mymul.py
user1@tensor-submit-0:~$ cat > test.submit << EOF 
universe = vanilla

# Files
executable = mymul.py
output = mymul.out
error = mymul.err
log = test.log

# File transfer behavior
ShouldTransferFiles = YES
WhenToTransferOutput = ON_EXIT

# Run job once
queue

EOF
user1@tensor-submit-0:~$ condor_submit test.submit 
Submitting job(s).
1 job(s) submitted to cluster 1.
user1@tensor-submit-0:~$ condor_wait test.log 
All jobs done.
user1@tensor-submit-0:~$ cat mymul.out 
Running on tensor-wn-7bd54b548f-bd2mh
result of matrix multiplication
===============================
[[ 1.0000000e+00  2.9802322e-08 -6.7055225e-08 -5.9604645e-08
   1.1920929e-07  0.0000000e+00  2.3841858e-07 -4.7683716e-07]
 [ 0.0000000e+00  1.0000000e+00  2.9802322e-08  0.0000000e+00
   0.0000000e+00  2.3841858e-07  4.7683716e-07  0.0000000e+00]
 [ 0.0000000e+00  0.0000000e+00  9.9999994e-01  0.0000000e+00
   0.0000000e+00  4.7683716e-07  4.7683716e-07  0.0000000e+00]
 [-5.2154064e-08 -1.3038516e-08  9.6624717e-08  9.9999988e-01
  -5.9604645e-08  1.1920929e-07 -1.4901161e-08  2.3841858e-07]
 [-7.4505806e-09 -1.3411045e-07  2.9802322e-08 -4.4703484e-08
   9.9999982e-01 -5.9604645e-08 -5.9604645e-08 -4.7683716e-07]
 [ 0.0000000e+00 -8.9406967e-08  4.4703484e-08  0.0000000e+00
   5.9604645e-08  1.0000001e+00 -1.1920929e-07 -2.3841858e-07]
 [ 5.9604645e-08 -2.9802322e-08 -8.9406967e-08 -5.9604645e-08
   5.9604645e-08  1.7881393e-07  1.0000000e+00 -2.3841858e-07]
 [ 2.9802322e-08 -7.4505806e-08  2.2351742e-08  0.0000000e+00
   8.9406967e-08  1.7881393e-07 -5.9604645e-08  9.9999964e-01]]
===============================
```


## Changing the number of worker nodes

The provided YAML will start 3 worker nodes.

If you want to change the number of worker nodes at any time you can do it by altering the replica count in the **tensor-wn** deployment. 

For example:
```
kubectl scale --replicas=4 -n YOUR_NAMESPACE deployment/tensor-wn
```


