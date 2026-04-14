#!/usr/bin/env bash

set -euo pipefail

mapfile -t files < <(find kubernetes -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)

if [[ "${#files[@]}" -eq 0 ]]; then
  echo "Nenhum manifesto Kubernetes encontrado em kubernetes/."
  exit 1
fi

for file in "${files[@]}"; do
  if ! grep -Eq '^apiVersion:' "$file"; then
    echo "Manifesto sem apiVersion: $file"
    exit 1
  fi

  if ! grep -Eq '^kind:' "$file"; then
    echo "Manifesto sem kind: $file"
    exit 1
  fi
done

echo "Manifestos Kubernetes validados: ${#files[@]}"
