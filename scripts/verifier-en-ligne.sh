#!/usr/bin/env bash
# Outil : vérifie que l'application répond sur son URL publique.
# Les deux routes de santé sont exigées : /health (convention des plateformes) et /sante.
# Atelier (passation DEMO01) : l'application est publiée en local par scripts/publier.sh ; on vérifie
# http://localhost:$ATELIER_PORT, jamais URL_PUBLIQUE (la vraie URL du hackathon sur une machine d'équipe).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
if [ "$(cat passation/.code-equipe 2>/dev/null)" = "DEMO01" ]; then
  url="http://localhost:${ATELIER_PORT:-3000}"
else
  [ -n "${URL_PUBLIQUE:-}" ] || { echo "Variable URL_PUBLIQUE absente." >&2; exit 1; }
  url="$URL_PUBLIQUE"
fi
ok=0
for route in health sante; do
  if curl -fsS --max-time 5 -o /dev/null "$url/$route"; then
    echo "$url/$route : 200"
  else
    echo "$url/$route ne répond pas 200." >&2; ok=1
  fi
done
exit $ok
