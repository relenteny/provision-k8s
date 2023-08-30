################################################################################
# Image: k8s-provisioner:1.5.0
################################################################################

FROM relenteny/ansible:2.9.12

LABEL repository.url=https://github.com/relenteny/provision-k8s/images/k8s-provisioner
LABEL repository.tag=1.5.0
LABEL ansible.version=2.9.12

ARG KUBERNETES_VERSION=1.27.4
ARG HELM_VERSION=3.12.3
ARG DOCKER_VERSION=24.0.5

COPY --chown=alpine:alpine build/home/alpine /home/alpine

USER root

RUN set -x && \
    apk add --no-cache sudo openssh-client openssl jq && \
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
    helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard && \
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
    helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server && \
    helm repo add twuni https://helm.twun.io && \
    helm repo add chartmuseum https://chartmuseum.github.io/charts && \
    helm repo add bitnami https://charts.bitnami.com/bitnami && \
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
    ${HOME}/bin/install-requirements.sh ${HOME}/bin/requirements.txt

ENTRYPOINT [ "/home/alpine/bin/docker-entrypoint.sh" ]
