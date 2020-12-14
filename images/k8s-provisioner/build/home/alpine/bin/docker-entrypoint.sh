#!/bin/bash -l

option=$1

case "${option}" in
    provision)
        ${HOME}/bin/start-provision.sh provision
        ;;
    remove)
        ${HOME}/bin/start-provision.sh remove
        ;;
    shell)
        cd ${HOME}
        /bin/bash -l
        ;;
    *)
        echo "Execute option \"${option}\" is invalid. Please specify \"provision,\" \"remove,\" or \"shell.\""
        exit 1
esac
