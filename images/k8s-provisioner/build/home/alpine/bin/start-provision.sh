#!/bin/bash -l

provision_directive=$1

source "${HOME}/bin/functions.sh"

echo "Kubernetes provisioner."
echo " "

validate_environment

mkdir -p "${HOME}/kubernetes"

cd "${HOME}/kubernetes" || { echo "Error creating ${HOME}/kubernetes directory."; exit 1; }
rm -rf ./provision-k8s

git clone ${GIT_REPO}

cd provision-k8s || { echo "Error with provision-k8s directory."; exit 1; }
git checkout ${GIT_TAG}

cd "${HOME}/kubernetes/provision-k8s/ansible"  || { echo "Error changing to ${HOME}/Kubernetes/provision-k8s."; exit 1; }

if [[ -f "provision.sh" ]]
then
    chmod +x ./provision.sh
    ./provision.sh ${provision_directive}
    if [[ "${provision_directive}" == "provision" ]]
    then
        readme_file=$(ls ${HOME}/kubernetes/readme | grep README | head -1)
        kubectl create configmap -n ${PROVISION_NAMESPACE} ${README_CONFIGMAP} "--from-file=content=${HOME}/kubernetes/readme/${readme_file}" "--from-literal=filename=${readme_file}"
    fi
else
    echo "Unable to execute \"provision.sh.\" Ensure the Git project has a script named \"provision.sh\" in the ~/kubernetes/provision-k8s/ansible subdirectory."
    exit 1
fi
