Here is a very simple HTCondor submit file.
For more details see the HTCondor manual:
https://htcondor.readthedocs.io/en/latest/users-manual/submitting-a-job.html

Note: It is important that each job submission file sets:
request_cpus=<num>
request_memory=<num, in MBs>
request_gpus=<num>
request_os_image="<string>"

in order fo the job to actually run on the right resources.
Those values must match the requested WN resources
(see k8s/external_pool example file)

Using the example file
======================

If you want to use the example file, just create an executable
my_example.sh

and then invoke
condor_submit example_job.condor

Use
condor_q
to monitor its progress.

Note: If you do not have suitable execute resources already available, you may want to consider requesting more 
e.g. by following instructions in 
k8s/external_pool
 
