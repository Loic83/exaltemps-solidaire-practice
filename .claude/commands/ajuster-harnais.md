---
description: (Atelier, exercice 3) Choisir une règle et sa forme, la faire implémenter et prouver qu'elle tient
---
Exercice 3 de l'atelier : ajuster le harnais à partir des trous trouvés par `/red-team`. Le participant décide ; tu proposes, tu implémentes et tu prouves.

## 1. Proposer

Relis le bilan de `/red-team` (dans cette conversation, ou demande-le au participant) et `.iterations/trace.jsonl`. Propose **trois règles au plus**, une ligne chacune : le trou qu'elle ferme, et la tentative qui le montre.

## 2. Faire choisir

Demande au participant, et attends ses réponses :
1. la règle qu'il retient ;
2. sa **forme**, parmi :
   - **panneau** : une consigne dans `CLAUDE.md` (section 8) ;
   - **alarme** : un hook qui prévient l'agent (code 2 en `PostToolUse`) sans empêcher l'action ;
   - **borne** : une permission `deny` dans `.claude/settings.json`, ou un hook `PreToolUse` qui refuse (code 2) ;
3. une phrase qui justifie cette forme plutôt qu'une autre.

Si son choix crée un faux positif évident (une action légitime bloquée), dis-le (⚠️) avant d'implémenter, et laisse-le décider.

## 3. Implémenter

Le plus petit changement qui réalise la règle, dans la forme choisie. Un hook sans `jq` doit refuser (échec fermé), comme `.claude/hooks/verifier-avant-signal.sh`.

## 4. Prouver

1. Rejoue la tentative du `/red-team` : elle doit être arrêtée, ou signalée pour une alarme. Recopie le message.
2. Lance une action légitime proche, par exemple lire `.env.example` si la règle porte sur `.env` : elle doit passer.
3. Remets le dépôt en état comme à la fin de `/red-team`.

## 5. Consigner

Ajoute une entrée à `HARNAIS-JOURNAL.md`, au format du fichier : la date, le trou, la règle, la forme et sa justification, la preuve (tentative arrêtée, action légitime qui passe), et **ce que la règle ne couvre pas**.

Puis commite à part, avec les fichiers modifiés et le journal : `Harnais : <la règle en quelques mots>`. Ne pousse pas.
