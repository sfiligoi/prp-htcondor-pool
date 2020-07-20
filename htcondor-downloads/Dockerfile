FROM centos:centos7

RUN mkdir -p /opt/htcondor/downloads

# HTCondor needs registration to download the tarballs
# May need to update the URLs when these expire
RUN cd /opt/htcondor/downloads && curl -s -S -O http://parrot.cs.wisc.edu//symlink/20200520125952/8/8.8/8.8.9/1178adef83a874ba7ee03dfa86963620/condor-8.8.9-x86_64_Debian9-stripped.tar.gz
RUN cd /opt/htcondor/downloads && curl -s -S -O http://parrot.cs.wisc.edu//symlink/20200520125952/8/8.8/8.8.9/71fbd7b4a24fc26a50c9dc71beacc3ac/condor-8.8.9-x86_64_CentOS7-stripped.tar.gz
RUN cd /opt/htcondor/downloads && curl -s -S -O http://parrot.cs.wisc.edu//symlink/20200520125952/8/8.8/8.8.9/f29fb781fc08e433db0e0766c817d35c/condor-8.8.9-x86_64_CentOS8-stripped.tar.gz

RUN cd /opt/htcondor/downloads && curl -s -S -O http://parrot.cs.wisc.edu//symlink/20200520125952/8/8.8/8.8.9/993d4b374cf3406995a9564d0fe3d897/condor-8.8.9-x86_64_Ubuntu16-stripped.tar.gz
RUN cd /opt/htcondor/downloads && curl -s -S -O http://parrot.cs.wisc.edu//symlink/20200520125952/8/8.8/8.8.9/4c5b418c50bf8dec4d83ae08007c083c/condor-8.8.9-x86_64_Ubuntu18-stripped.tar.gz

