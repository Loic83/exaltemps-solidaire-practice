# La solution, écran par écran

## Règles communes

- Six créneaux de retrait le samedi : 9 h 00, 9 h 30, 10 h 00, 10 h 30, 11 h 00, 11 h 30.
- 8 foyers au plus par créneau.
- Un foyer est identifié par son numéro de carte, au format `B-` suivi de 4 chiffres (exemple : `B-0042`). Aucun nom, téléphone ni adresse n'est demandé.
- Un foyer ne réserve qu'un seul créneau par samedi.

## Écran 1 : les créneaux

- La liste des six créneaux du samedi, dans l'ordre horaire.
- Pour chaque créneau : l'heure et le nombre de places restantes (« 3 places »).
- Un créneau complet affiche « Complet » et ne peut pas être choisi.
- Un clic sur un créneau disponible ouvre l'écran 2.

## Écran 2 : la réservation

- Rappel du créneau choisi.
- Un champ « Numéro de carte » et un bouton « Réserver ».
- Numéro au mauvais format : message « Le numéro de carte a la forme B-0042. »
- Foyer déjà inscrit ce samedi : message « Cette carte a déjà un créneau ce samedi. »
- Réservation réussie : message « Votre créneau est réservé : samedi à <heure>. », et le nombre de places restantes baisse de 1.

## Écran 3 : la liste du bénévole

- Accessible par l'adresse `/benevole`, sans compte.
- Pour chaque créneau, dans l'ordre horaire : l'heure et les numéros de carte inscrits.
- Un créneau sans inscrit affiche « Aucun foyer ».
