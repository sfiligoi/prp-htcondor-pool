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


More HTCondor documentation in [the htcondor manual](http://research.cs.wisc.edu/htcondor/manual/v8.9/SubmittingaJob.html).

