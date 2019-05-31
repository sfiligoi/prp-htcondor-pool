# Personal HTCondor based off PRP JupyterLab 

To create a new deployment:

    kubectl create -n <mynamespace> -f my_condor.yaml

To log into the pod:

    kubectl get pods -n <mynamespace>
    exec -it <mypod>  -n <mynamespace> -- /bin/bash
    su - jovyan

Basic HTCondor commands:
* List queued jobs: 
    condor_q
* Submit a new job:
    condor_submit
* Check the avaialble resources:
    condor_status
* Delete a queued job:
    condor_rm


More HTCondor documentation in [the htcondor manual](https://htcondor.readthedocs.io/en/v8_8_3/users-manual/submitting-a-job.html).

Note: HTCondor also provides [Python bindings](https://htcondor.readthedocs.io/en/v8_8_3/apis/python-bindings/index.html). May not be the easiest to use, but they are avaialble.

