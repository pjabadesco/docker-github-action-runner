# base
FROM ubuntu:18.04

# set the github runner version
ARG RUNNER_VERSION="2.286.1"

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker
RUN apt-get install -y gettext-base 
# RUN apt-get update -qq && apt-get install -qqy \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     lxc \
#     iptables 

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

RUN curl -fsSL https://get.docker.com | sh

RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

RUN cd /home/docker \
    && curl -LO https://dl.k8s.io/release/v1.20.9/bin/linux/amd64/kubectl \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    # copy microk8s config to ~/.kube/config
    # run this in k8s01: microk8s config
    && mkdir /home/docker/.kube \
    && cd /home/docker/.kube 
#     vi config
# kubectl cluster-info
# kubectl --kubeconfig=test-cluster config unset clusters

COPY daemon.json /home/docker/daemon_raw.json
COPY daemon.json /home/docker/daemon.json
RUN mkdir -p /etc/docker
RUN ln -s /home/docker/daemon.json /etc/docker/daemon.json
RUN rm /home/docker/daemon.json

# RUN envsubst < /etc/docker/daemon_raw.json > /etc/docker/daemon.json
# RUN sed -i "s/__REGISTRY_URL__/$REGISTRY_URL/g" /etc/docker/daemon.json

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# RUN apt-get install -y dbus-user-session kmod uidmap iptables
# RUN apt-get install -y --reinstall linux-modules-5.10.47-generic
# RUN modprobe ip_tables

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
# RUN usermod -aG docker root
# RUN newgrp docker
RUN groupadd -g 998 rdocker
RUN usermod -aG rdocker docker
USER docker

# RUN curl -fsSL https://get.docker.com/rootless | sh
# # RUN dockerd-rootless-setuptool.sh install
# # RUN service docker start
# RUN export XDG_RUNTIME_DIR=/home/docker/.docker/run
# RUN export PATH=/home/docker/bin:$PATH
# RUN export DOCKER_HOST=unix:///home/docker/.docker/run/docker.sock
# RUN /home/docker/bin/dockerd-rootless.sh 

VOLUME ["/home/docker/.kube","/home/docker/actions-runner/_work"]

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
