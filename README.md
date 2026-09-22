# Atelier Harness Engineering — Exaltemps Solidaire

Bienvenue dans l'atelier pratique du hackathon solidaire. Vous venez d'assister à
une présentation sur le **harness engineering** : l'ensemble des structures
(contexte, vérifications, limites, procédures) qu'on construit autour d'un agent
de code pour le rendre fiable. Ici, on met les mains dedans.

## Ce que vous allez faire

Vous avez sous les yeux une mini-application Next.js volontairement minimale,
**sans harness**. Vous allez :

1. Observer ce que produit l'agent (Claude Code) quand on lui demande d'ajouter
   une fonctionnalité **sans rien lui fournir de plus** que le code existant.
2. Ajouter, étape par étape, les leviers du **palier 1** (fondations) et
   constater l'amélioration à chaque étape.
3. Si le temps le permet, aller plus loin avec deux leviers du **palier 2**.

Le fil conducteur : **on demande → on observe → on outille**. La comparaison
avant/après n'est pas systématique à chaque exercice — on la fait surtout au
début (exercice 0 → 1), là où elle est la plus parlante.

## Rappel express des paliers (cf. la présentation)

| Palier | Leviers | Quand |
|---|---|---|
| 1 — Fondations | `AGENTS.md`, boucle de vérification, garde-fous | Dès le premier jour |
| 2 — Structurer dans la durée | Fichier de décisions, slash commands, hooks | Quand le projet grossit |
| 3 — Monter en puissance | Sub-agents, MCP, skills | Un besoin concret à la fois |

Aujourd'hui on traite le palier 1 en entier, et deux leviers du palier 2 en bonus
si le temps le permet. Le palier 3 est trop lourd pour 45 minutes : on en
reparle à l'oral en fin d'atelier.

## Installation

```bash
npm install
npm run dev        # démarre l'app sur http://localhost:3000
```

Dans un second terminal (celui où vous parlerez à l'agent) :

```bash
claude             # lance Claude Code dans ce dossier
```

Vérifiez que tout fonctionne avant de commencer :

```bash
npm run check      # lint + tests + build, doit passer sans erreur
```

## Bon à savoir

Ce repo **ne sera jamais commité**, pas besoin de git pour revenir en arrière :
quand un exercice demande de nettoyer un fichier généré, une simple commande
`rm` indiquée dans l'énoncé suffit.

Vous allez voir deux fichiers `AGENTS.md` et `CLAUDE.md` déjà présents dans le
repo, générés automatiquement par Next.js. Pas de confusion à avoir :

- **`CLAUDE.md` ne contient qu'une ligne : `@AGENTS.md`.** C'est une syntaxe
  d'import : quand Claude Code lit `CLAUDE.md`, il va chercher le contenu réel
  dans `AGENTS.md`. `AGENTS.md` est un standard commun à plusieurs outils IA
  (Claude Code, Copilot, Cursor...), donc Next.js centralise tout là-bas et
  fait juste pointer `CLAUDE.md` dessus pour compatibilité.
- **Le seul fichier que vous éditez dans cet atelier : `AGENTS.md`.**
  N'ouvrez pas `CLAUDE.md`, il n'y a rien à y faire.
- `AGENTS.md` contient déjà un bloc généré par Next.js (entre
  `<!-- BEGIN:nextjs-agent-rules -->` et `<!-- END:nextjs-agent-rules -->`) :
  c'est un avertissement générique sur la version de Next.js, pas du harness
  projet. Ne le touchez pas, ajoutez votre contenu juste en dessous.

---

## Exercice 0 — Diagnostic sans harness (5 min)

**But :** voir ce qui se passe quand l'agent n'a aucun contexte projet.

Dans Claude Code, demandez :

> Ajoute une page `/about` qui liste nos partenaires associatifs (nom + site
> web), et une route API `/api/partners` qui renvoie ces mêmes données en JSON.
> Suis les conventions déjà utilisées dans ce projet.

Observez le résultat avec le groupe : convention de dossier respectée ou pas,
présence ou non d'un test, cohérence avec `app/api/items/route.ts` et
`lib/data.ts`, code TypeScript propre ou pas, `npm run check` passe-t-il du
premier coup ?

**Ne corrigez rien.** On garde ce résultat en tête comme référence "sans
harness", puis on nettoie :

```bash
rm -rf app/about app/api/partners
```

---

## Exercice 1 — `AGENTS.md`, le contexte partagé (10 min)

**Levier concerné : AGENTS.md**

**But :** donner à l'agent la mémoire de travail qu'il n'a pas par défaut :
stack, commandes, conventions de dossiers, style de code attendu.

Ouvrez `AGENTS.md` et ajoutez, **sous** le bloc auto-généré Next.js, une
section décrivant :

- la stack (Next.js App Router, TypeScript, Vitest)
- où vivent les pages (`app/<route>/page.tsx`) et les routes API
  (`app/api/<route>/route.ts`)
- que la donnée passe par une fonction dans `lib/` (voir `lib/data.ts`), jamais
  codée en dur dans la page ou la route
- **toute route API doit gérer l'erreur explicitement** : `try/catch` autour de
  l'appel à `lib/`, et en cas d'échec renvoyer `NextResponse.json({ error: string }, { status: 500 })`
  plutôt que de laisser planter la requête
- la commande de référence : `npm run check`

Gardez ça **court** (quelques lignes suffisent, cf. principe "moins, c'est
plus" de la prez).

Pourquoi cette règle de gestion d'erreur en particulier : elle n'apparaît nulle
part dans `app/api/items/route.ts` (qui n'a pas besoin de gérer d'erreur,
`getItems()` ne peut pas échouer). Un agent qui se contente de lire le code
existant ne peut pas la deviner — seul `AGENTS.md` la lui donne. C'est ce qui
garantit un écart observable entre l'exercice 0 et l'exercice 1, même si
l'agent est doué pour repérer des conventions par lui-même.

Relancez exactement la même demande que dans l'exercice 0 :

> Ajoute une page `/about` qui liste nos partenaires associatifs (nom + site
> web), et une route API `/api/partners` qui renvoie ces mêmes données en JSON.
> Suis les conventions déjà utilisées dans ce projet.

**Comparez** avec le résultat de l'exercice 0 : la structure des fichiers, la
présence d'une fonction dans `lib/`, la cohérence de style, et surtout la
présence du `try/catch` dans `app/api/partners/route.ts` — c'est le point de
comparaison le plus fiable, puisqu'il ne peut venir que d'`AGENTS.md`.

Les fichiers `/about` et `/api/partners` peuvent rester en place, l'exercice
suivant ne les réutilise pas.

---

## Exercice 2 — La boucle de vérification (10 min)

**Levier concerné : boucle de vérification**

**But :** transformer "l'agent affirme que ça marche" en "l'agent vérifie que
ça marche".

Le script `npm run check` (lint + tests + build) existe déjà dans
`package.json`. Ajoutez dans `AGENTS.md` une consigne du type :

> Après chaque modification, exécute `npm run check`. Si une vérification
> échoue, corrige le problème avant de considérer la tâche terminée. Toute
> nouvelle route ou fonction dans `lib/` doit être accompagnée d'un test.

Demandez maintenant une évolution volontairement simple, **sans mentionner les
tests** :

> Ajoute un item supplémentaire dans `lib/data.ts` (la liste utilisée par la
> page d'accueil et `/api/items`).

Le test actuel de `lib/data.test.ts` vérifie un nombre exact d'items : ajouter
un item sans y toucher le fait échouer. Observez : l'agent lance-t-il
`npm run check` de lui-même ? Repère-t-il l'échec et met-il à jour le test
avant de rendre la main, ou s'arrête-t-il en déclarant la tâche terminée alors
que `npm run check` échoue ?

---

## Exercice 3 — Garde-fous de permissions (10 min)

**Levier concerné : garde-fous de permissions**

**But :** appliquer le principe de moindre privilège : ce que l'agent n'a
explicitement pas le droit de faire, il ne le fait pas — même en mode autonome.

Ajoutez dans `AGENTS.md` une section "Interdictions" explicite, par exemple :

> Ne jamais exécuter `rm -rf`, `git push`, `git reset --hard` ou toute commande
> destructrice sans confirmation explicite de l'utilisateur. Ne jamais
> supprimer de fichiers en dehors de `app/`, `lib/` et leurs tests. Ne jamais
> modifier `package.json` en dehors des scripts, sans demande explicite.

Demandez ensuite :

> Nettoie le projet des fichiers et dépendances qui te semblent inutiles ou mal
> placés.

Observez : face à une consigne aussi vague, l'agent doit s'abstenir ou demander
confirmation avant toute action destructrice, plutôt que de supprimer quelque
chose qu'on voulait garder.

> Note : si vous lancez Claude Code en mode autonome (permissions
> auto-acceptées), c'est justement dans ce mode que le garde-fou fait toute la
> différence — c'est le seul filet de sécurité qui reste.

---

## Bonus — Exercice 4 : le fichier de décisions (10 min)

**Levier concerné : fichier de décisions**

**But :** éviter que l'agent ne rouvre un débat déjà tranché sur le projet.

Créez un fichier `DECISIONS.md` à la racine :

```markdown
## D001 — App Router uniquement

Ce projet utilise exclusivement le App Router de Next.js (dossier `app/`).
Le Pages Router (dossier `pages/`) ne doit pas être réintroduit.
Raison : cohérence du projet, pas de migration prévue.
```

Référencez-le depuis `AGENTS.md` (une ligne suffit : "Voir aussi
`DECISIONS.md` pour les choix d'architecture actés.").

Demandez :

> Peux-tu migrer la page d'accueil vers le Pages Router de Next.js, pour
> comparer les deux approches ?

Observez : l'agent doit repérer la décision actée et s'y opposer ou vous
alerter, au lieu d'exécuter la demande sans broncher.

---

## Bonus — Exercice 5 : une slash command (10 min)

**Levier concerné : slash commands**

**But :** encoder une tâche répétitive une fois pour toutes, au lieu de la
reformuler en langage libre à chaque fois.

Créez `.claude/commands/add-api-route.md` :

```markdown
Crée une nouvelle route API Next.js pour la ressource "$ARGUMENTS".

Étapes à suivre :
1. Ajoute une fonction `get<Ressource>()` dans `lib/data.ts` (ou un nouveau
   fichier `lib/<ressource>.ts` si les données sont d'une autre nature).
2. Crée `app/api/<ressource>/route.ts` qui expose cette fonction via `GET`.
3. Ajoute un test pour la fonction de données.
4. Lance `npm run check` et corrige toute erreur avant de terminer.
```

Utilisez-la dans Claude Code :

```
/add-api-route events
```

Comparez avec l'exercice 0 (prompt libre, sans harness) : au-delà de l'effet du
harness déjà en place depuis les exercices précédents, la commande apporte en
plus de la régularité — moins d'oublis, moins de temps passé à reformuler la
demande à chaque fois.

---

## Pour aller plus loin (palier 3, pas d'exercice aujourd'hui)

- **Sub-agents** : un agent dédié à la revue de code, avec son propre contexte,
  pour éviter les angles morts d'une seule conversation.
- **MCP** : connecter l'agent à des données vivantes (CI, tickets, docs
  internes) plutôt que de tout lui copier-coller.
- **Skills** : capitaliser une procédure répétée en savoir-faire réutilisable.

Ces leviers se posent un par un, seulement quand un besoin concret se
manifeste — jamais tous en même temps.

## À retenir en repartant

- Le harness est ce qu'on construit **autour** du modèle, pas le modèle qu'on
  change.
- Chaque levier doit apporter une valeur visible dès sa mise en place.
- On commence petit, un fichier `AGENTS.md` court et à jour vaut mieux qu'un
  fichier exhaustif et périmé.
