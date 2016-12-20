FROM gitlab-registry.cern.ch/linuxsupport/cc7-base:latest

MAINTAINER Bertrand NOEL <bertrand.noel@cern.ch>, Ricardo Rocha <ricardo.rocha@cern.ch>

# cern base dependencies
ADD http://linux.web.cern.ch/linux/centos7/CentOS-CERN.repo /etc/yum.repos.d/CentOS-CERN.repo
RUN /usr/bin/rpm --import http://linuxsoft.cern.ch/cern/centos/7.1/os/x86_64/RPM-GPG-KEY-cern

# nice to have utilities
RUN yum install -y \
	ca-certificates \
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
RUN yum install -y \
	koji \
	rpm-build \
	rpmdevtools

ADD koji.conf /etc/koji.conf
ADD afs/etc /usr/vice/etc

RUN rpmdev-setuptree

# openstack clients
RUN echo $'\n\
[cci7-openstack-clients-stable] \n\
name=CERN rebuilds for OpenStack clients - QA \n\
baseurl=http://linuxsoft.cern.ch/internal/repos/openstackclients7-newton-stable/x86_64/os/ \n\
enabled=1 \n\
gpgcheck=0 \n\
priority=1 \n'\
>> /etc/yum.repos.d/openstackclients7-newton-stable.repo

RUN yum install -y \
	centos-release-openstack-newton
RUN sed -i 's/enabled=1/enabled=1\npriority=1/' /etc/yum.repos.d/CentOS-OpenStack-newton.repo

RUN yum install -y \
	python-barbicanclient \
	python-cryptography \
	python-decorator \
	python-heatclient \
	python-keystoneclient-x509 \
	python-openstackclient \
	python-swiftclient \
	python2-magnumclient

# docker client (upstream)
RUN echo $'\n\
[dockerrepo] \n\
name=Docker Repository \n\
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/ \n\
enabled=1 \n\
gpgcheck=1 \n\
gpgkey=https://yum.dockerproject.org/gpg \n'\
>> /etc/yum.repos.d/docker.repo

RUN yum install -y \
	docker-engine-1.10.3 \
	docker-engine-selinux-1.10.3

RUN curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose; \
	chmod +x /usr/local/bin/docker-compose

# kubectl client
RUN wget -q https://github.com/kubernetes/kubernetes/releases/download/v1.2.0/kubernetes.tar.gz; \
	tar zxvf kubernetes.tar.gz; \
	cp /kubernetes/platforms/linux/amd64/kubectl /usr/bin; \
	rm -rf /kubernetes

ENV SHELL=bash

ADD entry.sh /entry.sh

ENTRYPOINT /entry.sh
