#!/usr/bin/env bash
# Outil (atelier) : met l'application en ligne sur URL_PUBLIQUE, c'est-à-dire http://localhost:$PORT.
# Construit, arrête la version précédemment publiée, démarre la nouvelle en arrière-plan.
# Usage : scripts/publier.sh   (journaux dans .iterations/build.log et .iterations/app.log)
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
port="${PORT:-3000}"
mkdir -p .iterations

if ! npm run build > .iterations/build.log 2>&1; then
  echo "Build en échec : la version n'est pas publiée. Fin du journal (.iterations/build.log) :" >&2
  tail -n 20 .iterations/build.log >&2
  exit 1
fi

if [ -f .iterations/app.pid ] && kill -0 "$(cat .iterations/app.pid)" 2>/dev/null; then
  kill "$(cat .iterations/app.pid)"
  sleep 1
fi
if curl -fsS -o /dev/null --max-time 2 "http://localhost:$port/" 2>/dev/null; then
  echo "Le port $port est déjà utilisé par un autre programme (npm run dev ?) : arrête-le, puis relance." >&2
  exit 1
fi

nohup ./node_modules/.bin/next start -p "$port" > .iterations/app.log 2>&1 &
echo $! > .iterations/app.pid

for _ in $(seq 30); do
  if curl -fsS -o /dev/null --max-time 2 "http://localhost:$port/" 2>/dev/null; then
    echo "Version publiée sur http://localhost:$port (journal : .iterations/app.log)."
    exit 0
  fi
  sleep 1
done
echo "L'application ne répond pas sur le port $port après 30 secondes. Fin du journal (.iterations/app.log) :" >&2
tail -n 20 .iterations/app.log >&2
exit 1
