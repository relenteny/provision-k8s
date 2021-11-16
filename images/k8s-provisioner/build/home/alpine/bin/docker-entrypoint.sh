#!/bin/bash -l

case "${PROVISION_DIRECTIVE}" in
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
        echo "Execute option \"${PROVISION_DIRECTIVE}\" is invalid. Please specify \"provision,\" \"remove,\" or \"shell.\""
        exit 1
esac
