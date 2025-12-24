#!/usr/bin/env bash
set -euo pipefail

NS="${1:-}"
if [[ -z "$NS" ]]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

kc() { kubectl "$@"; }

echo "Checking namespace: $NS"
if ! kc get --no-headers ns "$NS" -o wide >/dev/null 2>&1; then
  echo "Namespace '$NS' not found."
  exit 1
fi

echo "Listing resources in $NS with finalizers (may take a bit)..."
# Collect namespaced resource types, then check each type if any objects containing finalizer
mapfile -t RES_TYPES < <(kc api-resources --verbs=list --namespaced -o name)
FINALIZER_FOUND=0
for r in "${RES_TYPES[@]}"; do
  # Skip known noisy types if desired (uncomment as needed)
  # [[ "$r" == "events" ]] && continue
  OUT="$(kc get "$r" -n "$NS" -o json 2>/dev/null || true)"
  if [[ -z "$OUT" ]]; then
    continue
  fi
  COUNT_WITH_FIN=$(jq '[.items[] | select(.metadata.finalizers | length > 0)] | length' <<<"$OUT")
  if [[ "$COUNT_WITH_FIN" -gt 0 ]]; then
    FINALIZER_FOUND=1
    echo "Resource type '$r' has $COUNT_WITH_FIN item(s) with finalizers:"
    jq -r '.items[] | select(.metadata.finalizers | length > 0) | "\(.kind)/\(.metadata.name): \(.metadata.finalizers | join(", "))"' <<<"$OUT"
  fi
done

if [[ "$FINALIZER_FOUND" -eq 0 ]]; then
  echo "No blocking finalizers found. If the namespace is still Terminating, check apiserver logs or admission webhooks."
  exit 0
fi

echo '====================================='
echo "Attempting graceful cleanup of namespaced resources with finalizers..."
for r in "${RES_TYPES[@]}"; do
  OUT="$(kc get "$r" -n "$NS" -o json 2>/dev/null || true)"
  if [[ -z "$OUT" ]]; then
    continue
  fi
  ITEMS_WITH_FIN=$(jq -r '.items[] | select(.metadata.finalizers | length > 0) | .metadata.name' <<<"$OUT")
  if [[ -n "$ITEMS_WITH_FIN" ]]; then
    while read -r name; do
      [[ -z "$name" ]] && continue
      echo "Patching $r/$name in $NS, removing its finalizer"
      kc patch ns "$NS" -p '{"metadata":{"finalizers":[]}}' --type=merge      
    done <<<"$ITEMS_WITH_FIN"
  fi
done
echo "Waiting briefly after cleanup..."
sleep 5

echo "Re-checking if namespace remains"
if ! kc get --no-headers ns "$NS" >/dev/null 2>&1; then
  echo "Namespace '$NS' cleared."
  exit 0
else
  echo "Namespace is still Terminating, check apiserver logs or admission webhooks."
  exit 1
fi
