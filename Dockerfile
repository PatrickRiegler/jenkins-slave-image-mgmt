# https://github.com/redhat-cop/containers-quickstarts/tree/master/jenkins-slaves/jenkins-slave-image-mgmt
FROM openshift3/jenkins-slave-base-rhel7


MAINTAINER HAKA6-Pacemakers <HAKA6-Pacemakers@six-group.com>

LABEL com.redhat.component="jenkins-slave-image-mgmt" \
      name="jenkins-slave-image-mgmt" \
      architecture="x86_64" \
      io.k8s.display-name="Jenkins Slave Image Management" \
      io.k8s.description="Image management tools on top of the jenkins slave base image" \
      io.openshift.tags="openshift,jenkins,slave,copy"
USER root

RUN yum repolist > /dev/null && \
    yum clean all && \
    INSTALL_PKGS="skopeo" && \
    yum install -y --enablerepo=rhel-7-server-extras-rpms --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

ADD *.sh /usr/bin/

USER 1001
