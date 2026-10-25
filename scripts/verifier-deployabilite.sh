#!/usr/bin/env bash
# Outil : vérifie le contrat de déployabilité (docs/contrat-deployabilite.md).
# Deux niveaux, pour illustrer panneau, alarme, borne :
#   BORNE  : un .env ou un secret suivi par git, ou la passation commitée. Code de sortie 1.
#            Le hook verifier-avant-signal.sh refuse alors le signal à PM Lab.
#   ALARME : un élément du contrat manque. Signalé, sans bloquer.
# Usage : scripts/verifier-deployabilite.sh [--construire]
#   --construire : reconstruit et démarre l'application avec Docker, si Docker est disponible.
set -uo pipefail
bornes=0
borne()  { echo "BORNE  : $1" >&2; bornes=$((bornes + 1)); }
alarme() { echo "ALARME : $1"; }

# Bornes : rien de secret ni de personnel dans le dépôt
for f in $(git ls-files | grep -E '(^|/)\.env(\..+)?$' | grep -v -E '(^|/)\.env\.example$'); do
  borne "$f est suivi par git : retire-le (git rm --cached $f) et considère ses secrets comme compromis"
done
if git grep -nIE 'sk-[A-Za-z0-9_-]{16,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY' -- . ':!scripts/verifier-deployabilite.sh' >/dev/null 2>&1; then
  borne "secret probable dans un fichier suivi : git grep -nIE 'sk-|AKIA|PRIVATE KEY' pour le voir"
fi
git ls-files | grep -q -E '^passation/' && borne "le dossier passation/ est commité (documents de l'association)"

# Alarmes : le contrat, élément par élément
[ -f Dockerfile ] || [ -f docker-compose.yml ] || [ -f compose.yaml ] || alarme "ni Dockerfile ni docker-compose.yml à la racine (règle 1)"
[ -f .env.example ] || alarme "pas de .env.example (règle 2)"
[ -f DEPLOIEMENT.md ] || alarme "pas de DEPLOIEMENT.md (règle 8)"
# En App Router, une route se définit par son chemin (src/app/health/route.ts), pas par une chaîne dans le code.
for r in health sante; do
  compgen -G "src/app/$r/route.*" >/dev/null || compgen -G "app/$r/route.*" >/dev/null || [ -f "public/$r" ] \
    || grep -rqE "[\"'\`]/${r}[\"'\`]" --include='*.ts' --include='*.js' --include='*.mjs' src app server 2>/dev/null \
    || alarme "pas de route /$r : src/app/$r/route.ts, ou public/$r pour un site statique (règle 5)"
done

# Préconisation : construire avec Docker, seulement s'il est disponible
if [ "${1:-}" = "--construire" ]; then
  if command -v docker >/dev/null 2>&1; then
    docker compose up --build -d && echo "Construit et démarré avec Docker." || alarme "docker compose up --build échoue (règle 1)"
  else
    echo "Docker n'est pas disponible sur cette machine : construction Docker non vérifiée (préconisation)."
  fi
fi

if [ "$bornes" -gt 0 ]; then
  echo "Contrat de déployabilité : $bornes borne(s) franchie(s). À corriger avant de signaler la version." >&2
  exit 1
fi
echo "Contrat de déployabilité : aucune borne franchie."
