# Personal HTCondor based off PRP JupyterLab 
kubectl create -n <mynamespace> -f my_condor.yaml

kubectl get pods -n <mynamespace>
exec -it <mypod>  -n <mynamespace> -- /bin/bash
# su - jovyan


