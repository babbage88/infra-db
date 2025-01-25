#!/bin/sh
set -e
echo "Waiting for init-infradb job to succeed..."
while true; do
	job_status=$(curl -sSk -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
		-H "Accept: application/json" \
		--cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
		https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/apis/batch/v1/namespaces/default/jobs/init-infradb |
		jq -r '.status.succeeded')
	if [ "$job_status" = "1" ]; then
		echo "Job init-infradb completed successfully."
		break
	elif [ "$job_status" = "null" ]; then
		echo "Job init-infradb is not found or has not started yet."
	else
		echo "Job init-infradb is still running or failed."
	fi
	sleep 5
done
