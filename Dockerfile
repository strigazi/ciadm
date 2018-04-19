FROM gitlab-registry.cern.ch/linuxsupport/cc7-base:latest

MAINTAINER Bertrand NOEL <bertrand.noel@cern.ch>, Ricardo Rocha <ricardo.rocha@cern.ch>

# cern base dependencies
ADD http://linux.web.cern.ch/linux/centos7/CentOS-CERN.repo /etc/yum.repos.d/CentOS-CERN.repo
RUN /usr/bin/rpm --import http://linuxsoft.cern.ch/cern/centos/7.3/os/x86_64/RPM-GPG-KEY-cern

# nice to have utilities
RUN yum install -y \
	ca-certificates \
        git \
	man-pages \
	vim \
	wget \
	yum-plugin-priorities

# CERN CA
ADD cerngridca.crt /etc/pki/ca-trust/source/anchors/cerngridca.crt
ADD cernroot.crt /etc/pki/ca-trust/source/anchors/cernroot.crt
RUN update-ca-trust

# krb and afs configuration
RUN yum -y install \
	krb5-workstation \
	openafs-krb5
ADD krb5.conf /etc/krb5.conf

# rpm/koji rpms and setup
RUN yum install -y --disablerepo=extras \
	koji

RUN yum install -y \
	rpm-build \
	rpmdevtools

ADD koji.conf /etc/koji.conf
ADD afs/etc /usr/vice/etc

RUN rpmdev-setuptree

# openstack clients
RUN echo $'\n\
[cci7-openstack-clients-stable] \n\
name=CERN rebuilds for OpenStack clients - QA \n\
baseurl=http://linuxsoft.cern.ch/internal/repos/openstackclients7-queens-stable/x86_64/os/ \n\
enabled=1 \n\
gpgcheck=0 \n\
priority=1 \n'\
>> /etc/yum.repos.d/openstackclients7-queens-stable.repo

RUN echo $'\n\
[centos7-cloud-openstack-queens] \n\
name=Openstack RDO \n\
baseurl=http://linuxsoft.cern.ch/cern/centos/7/cloud/x86_64/openstack-queens \n\
enabled=1 \n\
priority=1 \n\
gpgcheck=0 \n'\
>> /etc/yum.repos.d/centos7-cloud-openstack-queens.repo

RUN yum install -y \
	python-barbicanclient \
	python-decorator \
	python-heatclient \
	python-ironic-inspector-client \
	python-keystoneclient-x509 \
	python-openstackclient \
	python-swiftclient \
	python2-cryptography \
	python2-ironicclient \
	python2-magnumclient \
	python2-manilaclient \
	python2-mistralclient

RUN yum localinstall -y http://cbs.centos.org/kojifiles/packages/python-magnumclient/2.9.0/1.el7/noarch/python2-magnumclient-2.9.0-1.el7.noarch.rpm

# docker client (upstream)
RUN echo $'\n\
[docker-ce-stable] \n\
name=Docker CE Stable - $basearch \n\
baseurl=https://download.docker.com/linux/centos/7/$basearch/stable \n\
enabled=1 \n\
gpgcheck=0 \n\
gpgkey=https://download.docker.com/linux/centos/gpg \n'\
>> /etc/yum.repos.d/docker.repo

RUN yum install -y \
	docker-ce-17.06.1.ce

RUN curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose; \
	chmod +x /usr/local/bin/docker-compose

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v1.9.3/bin/linux/amd64/kubectl > /usr/local/bin/kubectl; \
	chmod +x /usr/local/bin/kubectl

RUN curl -o helm.tar.gz https://kubernetes-helm.storage.googleapis.com/helm-v2.8.2-linux-amd64.tar.gz; \
    mkdir -p helm; tar zxvf helm.tar.gz -C helm; cp helm/linux-amd64/helm /usr/local/bin; rm -rf helm*

ENV SHELL=bash

ADD entry.sh /entry.sh

CMD /entry.sh
