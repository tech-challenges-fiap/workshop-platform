#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-sa-east-1}"
CLUSTER_NAME="${CLUSTER_NAME:-workshop-platform-shared-cluster}"
NODEGROUP_NAME="${NODEGROUP_NAME:-workshop-platform-shared-default}"
INGRESS_NAMESPACE="${INGRESS_NAMESPACE:-ingress-nginx}"
INGRESS_SERVICE_NAME="${INGRESS_SERVICE_NAME:-ingress-nginx-controller}"
DELETE_INGRESS_SERVICE="${DELETE_INGRESS_SERVICE:-true}"

if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI is required." >&2
  exit 1
fi

nodegroup_status="$(
  aws eks describe-nodegroup \
    --region "${AWS_REGION}" \
    --cluster-name "${CLUSTER_NAME}" \
    --nodegroup-name "${NODEGROUP_NAME}" \
    --query 'nodegroup.status' \
    --output text
)"

case "${nodegroup_status}" in
  ACTIVE)
    current_max_size="$(
      aws eks describe-nodegroup \
        --region "${AWS_REGION}" \
        --cluster-name "${CLUSTER_NAME}" \
        --nodegroup-name "${NODEGROUP_NAME}" \
        --query 'nodegroup.scalingConfig.maxSize' \
        --output text
    )"

    max_size="${current_max_size}"
    if [ "${max_size}" -lt 1 ]; then
      max_size=1
    fi

    aws eks update-nodegroup-config \
      --region "${AWS_REGION}" \
      --cluster-name "${CLUSTER_NAME}" \
      --nodegroup-name "${NODEGROUP_NAME}" \
      --scaling-config "minSize=0,maxSize=${max_size},desiredSize=0" >/dev/null

    echo "Scale-down requested for node group ${NODEGROUP_NAME} in ${CLUSTER_NAME}."
    ;;
  UPDATING)
    echo "${NODEGROUP_NAME} is already updating in ${CLUSTER_NAME}."
    ;;
  *)
    echo "${NODEGROUP_NAME} is ${nodegroup_status}; scale-down is only requested from ACTIVE state." >&2
    exit 1
    ;;
esac

if [ "${DELETE_INGRESS_SERVICE}" != "true" ]; then
  echo "Ingress service deletion skipped because DELETE_INGRESS_SERVICE=${DELETE_INGRESS_SERVICE}."
  exit 0
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; node group was scaled down, but ingress Load Balancer was not deleted." >&2
  exit 0
fi

kubeconfig_file="$(mktemp)"
trap 'rm -f "${kubeconfig_file}"' EXIT

aws eks update-kubeconfig \
  --region "${AWS_REGION}" \
  --name "${CLUSTER_NAME}" \
  --kubeconfig "${kubeconfig_file}" >/dev/null

kubectl --kubeconfig "${kubeconfig_file}" \
  delete service "${INGRESS_SERVICE_NAME}" \
  --namespace "${INGRESS_NAMESPACE}" \
  --ignore-not-found

echo "Ingress service ${INGRESS_NAMESPACE}/${INGRESS_SERVICE_NAME} deleted or already absent."
