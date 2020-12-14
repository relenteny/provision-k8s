#!/bin/bash -l

provision_directive=$1

ansible_command="ansible-playbook --connection=local --inventory 127.0.0.1, provision-k8s.yaml -e cluster_hostname=${CLUSTER_HOSTNAME} -e cluster_hostname=${CLUSTER_HOSTNAME} -e cluster_configuration=${CLUSTER_CONFIGURATION} -e cluster_support_namespace=${CLUSTER_SUPPORT_NAMESPACE} -e output_root=/home/alpine/mapped-home"

if [[ "${provision_directive}" == "provision" ]]
then
    eval ${ansible_command}
else
    ansible_command="${ansible_command} -e \"uninstall=true\""
    eval ${ansible_command}
fi