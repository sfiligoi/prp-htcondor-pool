# Personal HTCondor based off PRP JupyterLab 

To create a new deployment:
    kubectl create -n <mynamespace> -f my_condor.yaml

To log into the pod:
    kubectl get pods -n <mynamespace>
    exec -it <mypod>  -n <mynamespace> -- /bin/bash
    su - jovyan



