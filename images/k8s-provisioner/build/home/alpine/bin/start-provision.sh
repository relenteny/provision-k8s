#!/bin/bash -l

provision_directive=$1

source "${HOME}/bin/functions.sh"

echo "Kubernetes provisioner."
echo " "

validate_environment

# Update container hosts file
sudo bash -c 'docker_ip=$(dig +short host.docker.internal);grep -q -F "${docker_ip}   ${CLUSTER_HOSTNAME}" /etc/hosts || echo "${docker_ip}   ${CLUSTER_HOSTNAME}" >> /etc/hosts'

cd "${mapped_home}/kubernetes/provision-k8s/ansible"  || { echo "Error changing to ${mapped_home}/Kubernetes/provision-k8s."; exit 1; }

if [[ -f "provision.sh" ]]
then
    chmod +x ./provision.sh
    ./provision.sh ${provision_directive}
else
    echo "Unable to execute \"provision.sh.\" Ensure the Git project has a script named \"provision.sh\" in the ~/kubernetes/provision-k8s/ansible subdirectory."
    exit 1
fi
