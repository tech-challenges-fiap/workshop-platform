#!/usr/bin/env bash

set -euo pipefail

mapfile -t files < <(find kubernetes -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)

if [[ "${#files[@]}" -eq 0 ]]; then
  echo "No Kubernetes manifests found in kubernetes/."
  exit 1
fi

for file in "${files[@]}"; do
  if ! grep -Eq '^apiVersion:' "$file"; then
    echo "Manifest missing apiVersion: $file"
    exit 1
  fi

  if ! grep -Eq '^kind:' "$file"; then
    echo "Manifest missing kind: $file"
    exit 1
  fi
done

echo "Validated Kubernetes manifests: ${#files[@]}"
