# Projet TSSR 🚀
Script & autre joyeuseté réalisé lors du parcours TSSR au CEFIM.
## Importer ce repo 
```
$repo = "nodoby-dock/PROJET_TSSR"
>> $zipUrl = "https://github.com/$repo/archive/refs/heads/main.zip"
>> $zipFile = "projet-test.zip"
>> $destinationPath = "C:/Scripts/projet-test"
>>
>> # Supprime le dossier s'il existe
>> Remove-Item -Path $destinationPath -Recurse -Force -ErrorAction SilentlyContinue
>>
>> # Télécharge et extrait l'archive
>> Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile
>> Expand-Archive -Path $zipFile -DestinationPath $destinationPath -Force
>>
>> # Supprime l'archive ZIP
>> Remove-Item -Path $zipFile -Force 
```
# *WinServ-DC* ⚙️
## L'outil parfait pour installer et populate un DC

### Son fonctionnement : 

Le script "_Script_install_total" propose d'executer les scripts ci dessous.

Lors de son lancement manuel il créera un raccourci dans le dossier Startup afin de s'éxécuter apres chaque rédémarrage.
📍 Press "9" pour annuler cet option.


1️⃣ 1-Name&group : Renomme le poste, propose de rejoindre un domaine si nécessaire & vérifie l'adresse IP de la machine

2️⃣2-DC_creation : Installation d'un DC et promotion en tant que contrôleur

3️⃣3-import_user : Choix multiple permettant de généré des OUs et/ou de généré des utilisateurs, chacun à l'aide d'un fichier CSV qui doit être présent dans le dossier de lancement du script (ou alors un prompt demandera le chemin du script)


#
Merci de penser au pôce bleu 👍

✨✨✨

Spécial dédicace à la chauve-souris haricot

👇👇

🦃🦃 

(avec de l'imagination ça passe)

![Image ajoutée](Asset/tst.png)

