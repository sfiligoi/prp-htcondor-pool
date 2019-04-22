FROM centos:centos7

RUN mkdir -p /opt/htcondor/downloads

# HTCondor needs registration to download the tarballs
# May need to update the URLs when these expire
RUN cd /opt/htcondor/downloads && curl -s -S -O http://parrot.cs.wisc.edu//symlink/20190422031501/8/8.8/8.8.2/c78fec0fcf0fb53610b8ddc12a92be67/condor-8.8.2-x86_64_Debian9-stripped.tar.gz
RUN cd /opt/htcondor/downloads && curl -s -S -O http://parrot.cs.wisc.edu//symlink/20190422031501/8/8.8/8.8.2/53d9dbd463f42b50dc86e99a170902c4/condor-8.8.2-x86_64_RedHat7-stripped.tar.gz


