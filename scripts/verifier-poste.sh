#!/usr/bin/env bash
# Outil (atelier) : vérifie que le poste est prêt avant de lancer Claude Code.
# Usage : scripts/verifier-poste.sh   (à lancer à la racine du dépôt ; finit par « Poste prêt » si tout va bien)
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
ko=0
ok()   { echo "OK      $1"; }
ko()   { echo "À FAIRE $1"; ko=$((ko + 1)); }
info() { echo "INFO    $1"; }

v=$(node -v 2>/dev/null | sed 's/^v//; s/\..*//')
if [ -n "$v" ] && [ "$v" -ge 24 ]; then ok "Node.js $(node -v)"; else ko "Node.js 24 ou plus (trouvé : ${v:-aucun})"; fi
# Les hooks héritent du PATH du terminal qui lance claude : lancer claude depuis ce terminal.
for outil in npm npx jq curl git; do
  command -v "$outil" >/dev/null 2>&1 && ok "$outil" || ko "$outil à installer"
done
command -v docker >/dev/null 2>&1 && info "Docker présent (facultatif pour l'atelier)" || info "Docker absent (facultatif pour l'atelier)"

[ -d node_modules/next ] && ok "dépendances installées" || ko "dépendances : lancer npm ci"
if compgen -G "${PLAYWRIGHT_BROWSERS_PATH:-$HOME/Library/Caches/ms-playwright}/chromium-*" >/dev/null \
  || compgen -G "${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}/chromium-*" >/dev/null; then
  ok "Chromium de Playwright installé"
else
  ko "Chromium de Playwright : lancer npx playwright install chromium"
fi
[ "$(git config core.hooksPath)" = ".githooks" ] && ok "borne au commit active" || ko "borne au commit : lancer git config core.hooksPath .githooks"
[ -n "$(git config user.name)" ] && [ -n "$(git config user.email)" ] && ok "identité git" || ko "identité git : git config user.name et user.email"

[ -n "${CLE:-}" ] && ok "CLE définie" || ko "CLE : export CLE=practice"
attendu="http://localhost:${PORT:-3000}"
if [ "${URL_PUBLIQUE:-}" = "$attendu" ]; then ok "URL_PUBLIQUE=$attendu"; else ko "URL_PUBLIQUE : export URL_PUBLIQUE=$attendu (trouvé : ${URL_PUBLIQUE:-vide})"; fi
if curl -fsS -o /dev/null --max-time 2 "$attendu/" 2>/dev/null; then
  ko "le port ${PORT:-3000} est déjà utilisé : arrête le programme qui l'occupe (npm run dev ?)"
else
  ok "port ${PORT:-3000} libre"
fi

echo
echo "Lance claude depuis ce terminal : les hooks utilisent son PATH (npm, npx, jq)."
if [ "$ko" -eq 0 ]; then echo "Poste prêt."; else echo "$ko point(s) à faire avant l'atelier."; exit 1; fi
