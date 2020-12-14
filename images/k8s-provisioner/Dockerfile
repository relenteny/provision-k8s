################################################################################
# Image: k8s-provisioner:1.0.0
################################################################################

FROM relenteny/ansible:2.9.12

LABEL com.solutechconsulting.repository.url=https://github.com/relenteny/provision-k8s/images/k8s-provisioner
LABEL com.solutechconsulting.repository.tag=1.0.0
LABEL com.solutechconsulting.ansible.version=2.9.12

ARG KUBERNETES_VERSION=1.19.3
ARG HELM_VERSION=3.4.2
ARG DOCKER_VERSION=20.10.0

COPY --chown=alpine:alpine build/home/alpine /home/alpine

USER root

RUN set -x && \
    apk add --no-cache sudo openssh-client openssl && \
    curl -s https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz -o docker.tar.gz && \
    tar xf docker.tar.gz && \
    sudo mv docker/docker /usr/local/bin/ && \
    rm -rf docker && \
    rm docker.tar.gz && \
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin/kubectl && \
    curl -s https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
    tar xf helm.tar.gz && \
    sudo mv linux-amd64/helm /usr/local/bin/ && \
    rm -rf linux-amd64 && \
    rm helm.tar.gz && \
    echo "alpine    ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/alpine

USER alpine

RUN set -x && \
    chmod +x /home/alpine/bin/*.sh && \
    helm repo add stable https://charts.helm.sh/stable && \
    helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard && \
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
    ${HOME}/bin/install-requirements.sh ${HOME}/bin/requirements.txt

ENTRYPOINT [ "/home/alpine/bin/docker-entrypoint.sh" ]
