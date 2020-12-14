#!/bin/bash -l

provision_directive=$1
cluster_domain="$(hostname).com"
cluster_hostname="local.k8s.${cluster_domain}"
registry_hostname="local.k8s.registry.${cluster_domain}"
cluster_support_namespace="cluster-support"
cluster_configuration="development"

git_repo="git@github.com:relenteny/provision-k8s.git"
git_tag="1.0.0"

if [[ "${provision_directive}" == "" ]]
then
    provision_directive="provision"
fi

provisioner_image_version="1.0.0"
helm_dist_version="3.4.2"

uname=$(uname)
if [[ ${uname} == "Darwin" ]]
then
    host_os="mac"
    docker_product="Docker for Mac"
    docker_documentation="https://docs.docker.com/docker-for-mac/install/"
    helm_file="darwin-amd64"
else
    if [[ -n ${WSL_DISTRO_NAME} ]]
    then
        host_os="windows"
        docker_product="Docker for Windows"
        docker_documentation="https://docs.docker.com/docker-for-windows/install/"
        helm_file="linux-amd64"
        windows_hosts="/mnt/c/Windows/System32/drivers/etc/hosts"
        if [[ ! -w "${windows_hosts}" ]]
        then
            echo " "
            echo "***** Windows hosts file is not writable *****"
            echo " "
            echo "The current process is unable to make changes to the Windows hosts table. In order to configure access"
            echo "to the Kubernetes cluster, including access from WSL, the Windows hosts file needs to be updated."
            echo " "
            echo "There are various methods available to handle this issue. The most straightforward is to execute this"
            echo "script in a WSL session started with Administrator privileges (Run as administrator). Once the script has"
            echo "succesfully executed, subsequent WSL sessions will not require Administrator privileges."
            echo " "
            exit 1
        fi
    else
        echo "This script currently runs on either a Mac or in a Windows WSL 2 installation."
        exit 1
    fi
fi

grep -q -F "kubernetes.docker.internal" /etc/hosts || { echo "This script requires ${docker_product} with Kubernetes enabled to be installed and running."; exit 1;}

command -v kubectl >/dev/null
if [[ $? == 1 ]]
then
    echo " "
    echo "kubectl is not installed. Please enable Kubernetes support in ${docker_product}."
    echo "If ${docker_product} has not been installed, before executing this script,"
    echo "please install ${docker_product}."
    echo " "
    echo "The installation is available here: ${docker_documentation}"
    echo " "
    exit
fi

echo " "
echo "Retreiving provisioning code from GitHub."
echo " "

mkdir -p "${HOME}/kubernetes"

cd "${HOME}/kubernetes" || { echo "Error creating ${HOME}/kubernetes directory."; exit 1; }
rm -rf ./provision-k8s

git clone ${git_repo}

cd provision-k8s || { echo "Error with provision-k8s directory."; exit 1; }
git checkout ${git_tag}

image_output=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep "k8s-provisioner:${provisioner_image_version}")
if [[ -z "${image_output}" ]]
then
    echo " "
    echo "Building development images..."
    echo " "

    cd images/k8s-provisioner || { echo "Error with images/k8s-provisioner directory."; exit 1; }
    docker build . --tag k8s-provisioner:${provisioner_image_version}
fi

hosts_entry=$(grep -F "${cluster_hostname}" /etc/hosts)
if [[ "${provision_directive}" == "provision" ]] && [[ -z "${hosts_entry}" ]]
then
    echo " "
    echo " "
    echo "Updating hosts table. You may be asked for your password."
    echo " "
    grep -q -F "127.0.0.1       ${registry_hostname}" /etc/hosts || echo "127.0.0.1       ${registry_hostname}" | sudo tee -a /etc/hosts > /dev/null
    grep -q -F "127.0.0.1       ${cluster_hostname}" /etc/hosts || echo "127.0.0.1       ${cluster_hostname}" | sudo tee -a /etc/hosts > /dev/null

    if [[ "${host_os}" == "windows" && -w "${windows_hosts}" ]]
    then
        grep -q -F "127.0.0.1       ${registry_hostname}" ${windows_hosts} || echo "127.0.0.1       ${registry_hostname}" | sudo tee -a ${windows_hosts} > /dev/null
        grep -q -F "127.0.0.1       ${cluster_hostname}" ${windows_hosts} || echo "127.0.0.1       ${cluster_hostname}" | sudo tee -a ${windows_hosts} > /dev/null
    fi
fi

docker run --rm -t -v "/var/run/docker.sock:/var/run/docker.sock" -v "$HOME:/home/alpine/mapped-home" -e "CLUSTER_HOSTNAME=${cluster_hostname}" -e "REGISTRY_HOSTNAME=${registry_hostname}" -e "CLUSTER_SUPPORT_NAMESPACE=${cluster_support_namespace}" -e "CLUSTER_CONFIGURATION=${cluster_configuration}" -e "HOST_OS=${host_os}" -e "PROJECT_DIRECTORY=ansible" k8s-provisioner:${provisioner_image_version} ${provision_directive}

cd "${HOME}/kubernetes" || { echo "Error with kubernetes directory."; exit 1; }
rm -rf provision-k8s

if [[ "${provision_directive}" == "provision" ]]
then
    curl -s https://get.helm.sh/helm-v${helm_dist_version}-${helm_file}.tar.gz -o helm.tar.gz
    tar xf helm.tar.gz
    mkdir -p "${HOME}/.local/bin"
    cp ${helm_file}/helm "${HOME}/.local/bin/"
    echo " "
    echo "The helm command, version ${helm_dist_version}, has been installed in ${HOME}/.local/bin. Ensure"
    echo "${HOME}/.local/bin has been set in \$PATH."
    echo " "
    rm -rf ${helm_file}
    rm helm.tar.gz

    "${HOME}/.local/bin/helm" repo add stable https://charts.helm.sh/stable
    "${HOME}/.local/bin/helm" repo update

    if [[ "${cluster_configuration}" == "development" ]]
    then
        "${HOME}/.local/bin/helm" repo add local http://${cluster_hostname}/chartmuseum
    fi

    cd "${HOME}/kubernetes/docker-desktop" || { echo "Error with docker-desktop directory."; exit 1; }
    readme_file=$(find . -maxdepth 1 -name "README*" | sort -r | head -1)
    if [[ -f "${readme_file}" ]]
    then
        less "${readme_file}"
    fi
else
    hosts_entry=$(grep "${cluster_hostname}" /etc/hosts)
    if [[ -n "${hosts_entry}" ]]
    then
        echo " "
        echo " "
        echo "Updating hosts table. You may be asked for your password."
        echo " "
        sudo sed -i.bak "/${cluster_hostname}/d" /etc/hosts
        sudo sed -i.bak "/${registry_hostname}/d" /etc/hosts
        sudo rm /etc/hosts.bak
        if [[ "${host_os}" == "windows" && -w "${windows_hosts}" ]]
        then
            sed -i.bak "/${cluster_hostname}/d" ${windows_hosts}
            sed -i.bak "/${registry_hostname}/d" ${windows_hosts}
            rm ${windows_hosts}.bak
        fi
    fi
fi