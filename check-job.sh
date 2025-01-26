#!/bin/bash
echo "Waiting for init-infradb job to succeed..."
for ((i=1; i<=$RETRY; i++))
do
	echo "Retry Number: $i"
	job_status=$(curl -sSk -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
        -H "Accept: application/json" \
        --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
        https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/apis/batch/v1/namespaces/default/jobs/init-infradb |
        jq -r 'try (.status.succeeded) catch "500"' )
	not_found_status=$(curl -sSk -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
		-H "Accept: application/json" \
		--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
		https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/apis/batch/v1/namespaces/default/jobs/init-infradb |
		jq -r 'try (.code) catch "nil"')
	if [ "$job_status" = "1" ]; then
		echo "Job init-infradb completed successfully."
		exit 0
	elif [ "$not_found_status" = "404" ]; then
		echo "Job init-infradb is not found or has not started yet."
		if [ $i = $RETRY ]; then
			exit 404
		else
			break
		fi
	else
		echo "Job init-infradb is still running or failed."
		if [ $i = $RETRY ]; then
			exit 1
		else
			break
		fi
	fi
	sleep 5
done
