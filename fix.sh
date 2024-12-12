#!/bin/bash

# 네임스페이스 설정
NAMESPACE="default"

# 삭제 대상 리소스를 조회하고 필터링하는 함수
delete_resources() {
  local resource_type=$1
  local exclude_pattern=$2

  RESOURCES_TO_DELETE=$(kubectl get $resource_type -n $NAMESPACE --no-headers | awk '{print $1}' | grep -vE "$exclude_pattern")

  echo "The following $resource_type will be deleted in namespace '$NAMESPACE':"
  echo "$RESOURCES_TO_DELETE"

  if [ -n "$RESOURCES_TO_DELETE" ]; then
    for RESOURCE in $RESOURCES_TO_DELETE; do
      echo "Deleting $resource_type: $RESOURCE"
      kubectl delete $resource_type $RESOURCE -n $NAMESPACE
    done
  else
    echo "No $resource_type to delete."
  fi
}

# Service에서 kubernetes로 시작하는 서비스 제외하고 삭제
delete_resources "service" "^kubernetes"

# StatefulSet에서 kubernetes로 시작하는 StatefulSet 제외하고 삭제
delete_resources "statefulset" "^kubernetes"

# Deployment에서 kubernetes로 시작하는 Deployment 제외하고 삭제
delete_resources "deployment" "^kubernetes"

# PersistentVolumeClaim 삭제
kubectl delete pvc -n $NAMESPACE

# PersistentVolume 삭제
kubectl delete pv