#!/usr/bin/env bash
# Outil : vérifie que l'application répond sur son URL publique.
# Les deux routes de santé sont exigées : /health (convention des plateformes) et /sante.
set -uo pipefail
[ -n "${URL_PUBLIQUE:-}" ] || { echo "Variable URL_PUBLIQUE absente." >&2; exit 1; }
ok=0
for route in health sante; do
  if curl -fsS --max-time 5 -o /dev/null "$URL_PUBLIQUE/$route"; then
    echo "$URL_PUBLIQUE/$route : 200"
  else
    echo "$URL_PUBLIQUE/$route ne répond pas 200." >&2; ok=1
  fi
done
exit $ok
