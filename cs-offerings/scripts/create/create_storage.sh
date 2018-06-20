#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

PAID=false
OFFERING="free"
pvc_descriptor=${KUBECONFIG_FOLDER}/storage-free.yaml

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--paid)
				echo "Configured to setup a paid storage on ibm-cs"
				PAID=true
        OFFERING="paid"
        pvc_descriptor=${KUBECONFIG_FOLDER}/storage-paid.yaml
				;;
      --icp)
        echo "Configured to setup storage on IBM Cloud Private"
        ICP=true
        OFFERING="icp"
        pvc_descriptor=${KUBECONFIG_FOLDER}/storage-icp.yaml
        ;;
		esac
		shift
	done
}

Parse_Arguments $@

#if [ "${PAID}" == "true" ]; then
#	OFFERING="paid"
#elseif [ "${ICP}" == "true" ]; then
#    OFFERING="icp"
#  else
#  	OFFERING="free"
#  fi
#fi

#if [ "${PAID}" == "true" ]; then
	if [ "$(kubectl get pvc | grep blockchain-shared-pvc | awk '{ print $2 }')" != "Bound" ] || [ "$(kubectl get pvc | grep blockchain-composer-pvc | awk '{ print $2 }')" != "Bound" ]; then
		echo "The ${OFFERING} PVC does not seem to exist"
		echo "Creating PVC named blockchain-shared-pvc and blockchain-composer-pvc"

		# making a PVC on ibm-cs paid version
		echo "Running: kubectl create -f ${pvc_descriptor}"
		kubectl create -f ${pvc_descriptor}
		sleep 5

		while [ "$(kubectl get pvc | grep blockchain-shared-pvc | awk '{print $2 }')" != "Bound" ];
		do
			echo "Waiting for blockchain-shared-pvc to be bound"
			sleep 5
		done

		while [ "$(kubectl get pvc | grep blockchain-composer-pvc | awk '{print $2 }')" != "Bound" ];
		do
			echo "Waiting for blockchain-composer-pvc to be bound"
			sleep 5
		done
	else
		echo "The PVC with name blockchain-shared-pvc or blockchain-composer-pvc exists, not creating again"
		#echo "Note: This can be a normal storage and not a ibm-cs storage, please check for more details"
	fi
#else
#	if [ "$(kubectl get pvc | grep shared-pvc | awk '{print $3}')" != "shared-pv" ]; then
#		echo "The Persistant Volume does not seem to exist or is not bound"
#		echo "Creating Persistant Volume"

		# making a pv on kubernetes
#		echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/storage-free.yaml"
#		kubectl create -f ${KUBECONFIG_FOLDER}/storage-free.yaml
#		sleep 5
#		if [ "kubectl get pvc | grep shared-pvc | awk '{print $3}'" != "shared-pv" ]; then
#			echo "Success creating PV"
#		else
#			echo "Failed to create PV"
#		fi
#	else
#		echo "The Persistant Volume exists, not creating again"
#	fi

#fi
