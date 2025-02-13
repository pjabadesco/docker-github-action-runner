# base
FROM ubuntu:20.04

# set the GitHub runner version
ARG RUNNER_VERSION="2.322.0"

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker
RUN apt-get install -y gettext-base iputils-ping vim

RUN apt install -y software-properties-common && \
    add-apt-repository ppa:git-core/ppa -y   
RUN apt-get update && apt-get install git -y

# install python and the packages the code depends on along with jq to parse JSON
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip 

# Install Docker and Docker Compose
RUN apt-get update -y && apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg    
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io

RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# cd into the user directory, download, and unzip the GitHub Actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# Install kubectl
RUN cd /home/docker \
    && curl -LO https://dl.k8s.io/release/v1.20.9/bin/linux/amd64/kubectl \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && mkdir /home/docker/.kube \
    && cd /home/docker/.kube

COPY daemon.json /home/docker/daemon_raw.json
COPY daemon.json /home/docker/daemon.json
RUN mkdir -p /etc/docker
RUN ln -s /home/docker/daemon.json /etc/docker/daemon.json
RUN rm /home/docker/daemon.json

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# configure docker group and permissions
RUN groupadd -g 998 rdocker
RUN usermod -aG rdocker docker
USER docker

# fix Git pull problems
RUN git config --global http.postBuffer 1048576000
RUN git config --global http.timeout 300 
COPY .gitconfig /home/docker/.gitconfig

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]