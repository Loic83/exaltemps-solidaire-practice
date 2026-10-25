---
description: (Optionnel) Explique le commit d'une itération, pour comprendre l'architecture produite
argument-hint: [numéro de l'itération ; la dernière par défaut]
---
Explique au développeur ce qui a été produit pendant l'itération `$ARGUMENTS` (la dernière si rien n'est précisé). C'est une commande de lecture : tu ne modifies aucun fichier.

1. Retrouve le commit `Itération $ARGUMENTS : ...` dans `git log`, et lis son contenu avec `git diff <commit>~1 <commit>`.
2. Explique en 15 lignes au plus :
   - **ce que l'itération ajoute**, en une phrase, et le critère d'acceptation que sert chaque fichier touché ;
   - **où ça se place dans l'architecture** : quelle couche (page, composant, logique métier, route d'API, données), et comment les fichiers s'appellent entre eux. Si ça aide, ajoute un petit schéma en texte ;
   - **la logique métier** et le test qui la protège ;
   - **ce qui est provisoire** (données en dur, raccourci pris pour tenir le budget), à reprendre plus tard.
3. Termine par deux pistes de lecture : les deux fichiers qu'un développeur devrait ouvrir en premier pour comprendre, dans l'ordre.

Si le développeur veut un second regard, propose de lancer le sous-agent `reviewer` sur ce commit.
