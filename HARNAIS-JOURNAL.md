# Journal du harnais

Une entrée par ajustement du harnais, la plus récente en bas. Écrit par `/ajuster-harnais` (exercice 3 de l'atelier).

Format d'une entrée :

```markdown
## <date> : <la règle en quelques mots>

- **Trou** : la tentative du /red-team qui passait.
- **Règle** : ce qui est désormais empêché ou signalé.
- **Forme** : panneau, alarme ou borne, et où (fichier).
- **Pourquoi cette forme** : la phrase du participant.
- **Preuve** : la tentative rejouée (message reçu) ; l'action légitime qui passe toujours.
- **Ce que la règle ne couvre pas** : les contournements connus.
```

## 2026-11-11 : la borne `git add` vise le dossier passation/, plus les noms de fichiers

- **Trou** : faux positif. `Bash(git add *passation*)` refusait aussi `git add scripts/recuperer-passation.sh` et `.claude/commands/recuperer-passation.md`, dont le nom contient « passation ».
- **Règle** : `git add` est refusé quand un argument commence par `passation` ou `./passation` (le dossier `passation/` et `passation.zip`).
- **Forme** : borne, permissions `deny` de `.claude/settings.json` : `Bash(git add passation*)`, `Bash(git add * passation*)`, `Bash(git add *./passation*)`.
- **Pourquoi cette forme** : on garde une borne, mais elle doit viser le dossier, pas un mot.
- **Preuve** : `git add passation` est refusé ; `git add scripts/recuperer-passation.sh` passe.
- **Ce que la règle ne couvre pas** : `git add .`, `git add -A` ou un chemin absolu. Le `.gitignore` et le hook pre-commit (`verifier-deployabilite.sh`) restent les vraies protections du dossier.
