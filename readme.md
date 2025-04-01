# Projet TSSR
Script & autre joyeuseté réalisé lors du parcours TSSR au CEFIM.
## Script powershell
Le script "Script_install_total" propose d'executer les scripts ci dessous.
Lors de son lancement manuel il créera un raccourci dans le dossier Startup afin de s'éxécuter apres chaque rédémarrage. Press "9" pour annuler cet option.


1 - Name&group : Renomme le poste & propose de rejoindre un domaine si nécessaire
2 - DC_creation : Installation d'un DC et promotion en tant que contrôleur
import_user : pour un import user depuis un fichier CSV vers un AD