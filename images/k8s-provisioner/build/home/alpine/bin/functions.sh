#!/bin/bash

function get_response() {

    prompt=$1
    default_value=$2
    required_message=$3

    while true
    do
        if [[ -z "${default_value}" ]]
        then
            read -p "${prompt}: " response
        else
            read -p "${prompt} [${default_value}]: " response
            if [[ -z "${response}" ]]
            then
                response=${default_value}
            fi
        fi

        if [[ ! -z "${required_message}" && -z "${response}" ]]
        then
            echo "${required_message}"
            echo ""
        else
            break;
        fi
    done

    echo "${response}"
}

function validate_environment () {
    mapped_home=${HOME}/mapped-home

    if [[ ! -d "${mapped_home}" ]]
    then
        echo " "
        echo "Home directory has not been mapped. This script requires a home directory bind mount."
        echo " "
        exit 1
    fi

    if [[ -z "${CLUSTER_HOSTNAME}" ]]
    then
        echo " "
        echo "The cluster hostname has not been set. This script requires the cluster hostname to be set."
        echo " "
        exit 1
    fi

    if [[ ! -S "/var/run/docker.sock" ]]
    then
        echo " "
        echo "/var/run/docker.sock has not been mapped. This script requires that /var/run/docker.sock be mapped."
        echo " "
        exit 1
    else
        sudo sh -c "chmod 666 /var/run/docker.sock"
    fi

    mkdir -p ${HOME}/.kube
    find ${mapped_home}/.kube -maxdepth 1 -type f -exec cp {} ${HOME}/.kube/ \;
    chmod 600 ${HOME}/.kube/*

    if [[ -d "${mapped_home}/.ssh" ]]
    then
        setopt +o nomatch
        cp -r "${mapped_home}/.ssh" $HOME/.ssh
        chmod 700 $HOME/.ssh
        chmod 600 $HOME/.ssh/*
        chmod 644 $HOME/.ssh/*.pub
        setopt -o nomatch
    fi
}
