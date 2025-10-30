FROM ubuntu:25.04

ARG JENKINS_SWARM_VERSION=3.48
ENV EXECUTOR=3 LABELS= NAME= PASSWORD=
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Use optional remote ccache
# redis://YOUR_SERVER:6379
ENV CCACHE_REMOTE_STORAGE= CCACHE_RESHARE=true CCACHE_REMOTE_ONLY=

RUN useradd -m governikus -g users -u 1111
RUN apt-get update && \
    apt-get -y install openjdk-17-jre-headless tini python3-pip wget locales && \
    pip3 install --break-system-packages rbtools mercurial python-hglib && \
    rm -rf /var/lib/apt/lists/*
RUN wget -O /swarm-client.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD swarm.sh /
