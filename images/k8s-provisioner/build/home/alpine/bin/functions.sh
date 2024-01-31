#!/bin/bash

function validate_environment () {
    if [[ -z "${CLUSTER_HOSTNAME}" ]]
    then
        echo " "
        echo "The cluster hostname has not been set. This script requires the cluster hostname to be set."
        echo " "
        exit 1
    fi

    mkdir -p ${HOME}/.kube
    cp ${HOME}/config/config ${HOME}/.kube
    chmod 600 ${HOME}/.kube/*

    if [[ -n "${CLUSTER_IP}" ]]
    then
        sed "s|server: https://127.0.0.1:6443|https://${cluster_ip}:6443|" ${HOME}/.kube/config
    fi

    export K8S_AUTH_CONTEXT=$(kubectl config current-context)

    if [[ -f "${HOME}/config/ssh.tar" ]]
    then
        cd ${HOME}
        tar xf "${HOME}/config/ssh.tar"
        chmod 700 ${HOME}/.ssh
        chmod 600 ${HOME}/.ssh/*
    fi

    if [[ -f "${HOME}/config/minikube-profiles.tar" && "${K8S_AUTH_CONTEXT}" == "minikube" ]]
    then
        cd ${HOME}
        tar xf "${HOME}/config/minikube-profiles.tar"
        cp "${HOME}/config/ca.crt" ${HOME}/.minikube/ca.crt
        cp "${HOME}/config/ca.key" ${HOME}/.minikube/ca.key
        sed -i "s|certificate-authority: .*|certificate-authority: ${HOME}/.minikube/ca.crt|" ${HOME}/.kube/config
        profile=$(basename $(dirname$(cat ${HOME}/.kube/config | grep "client-certificate: " | cut -d':' -f2)))
        sed -i "s|client-certificate: .*|client-certificate: ${HOME}/.minikube/profiles/${profile}/client.crt|" ${HOME}/.kube/config
        sed -i "s|client-key: .*|client-key: ${HOME}/.minikube/profiles/${profile}/client.key|" ${HOME}/.kube/config
        chmod 600 ${HOME}/.minikube/ca.key
        chmod 644 ${HOME}/.minikube/ca.crt
    fi
}
