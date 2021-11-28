#!/bin/bash

working_dir=$(pwd)

createpod_dir="${HOME}/kubernetes"
if [[ -f "./create-pod.sh" ]]
then
    createpod_dir=$(pwd)
fi

provision_namespace="provision-k8s"
volume_configmap="provision-k8s-volume"
env_configmap="provision-k8s-env"

kubectl get namespace ${provision_namespace} >/dev/null 2>&1 
if [[ $? != 0 ]]
then
    kubectl create namespace ${provision_namespace}
fi

kubectl delete configmap ${volume_configmap} -n ${provision_namespace} >/dev/null 2>&1 
kubectl delete configmap ${env_configmap} -n ${provision_namespace} >/dev/null 2>&1 

cd ${HOME}
if [[ -d ".minikube" ]]
then
    tar cf ${working_dir}/minikube-profiles.tar .minikube/profiles
    minikube_config="--from-file=minikube-profiles.tar --from-file=$HOME/.minikube/ca.key --from-file=$HOME/.minikube/ca.crt"
fi
if [[ -d ".ssh" ]]
then
    tar cf ${working_dir}/ssh.tar .ssh
    ssh_config="--from-file=ssh.tar"
fi
cd ${working_dir}

kubectl create configmap ${env_configmap} -n ${provision_namespace} --from-env-file=./pod-env.txt
kubectl create configmap ${volume_configmap} -n ${provision_namespace} --from-file=$HOME/.kube/config ${minikube_config} ${ssh_config}

kubectl delete pod -n ${provision_namespace} k8s-provisioner > /dev/null 2>&1
kubectl create -n ${provision_namespace} -f ${createpod_dir}/provision-pod.yaml
kubectl wait --for=condition=ready pod k8s-provisioner -n ${provision_namespace}
kubectl logs -f -n ${provision_namespace} k8s-provisioner

rm -f minikube-profiles.tar ssh.tar pod-env.txt
