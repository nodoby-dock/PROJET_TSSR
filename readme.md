# Projet TSSR 🚀
Script & autre joyeuseté réalisé lors du parcours TSSR au CEFIM.
## Importer cd repo 
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
>>
## Script powershell ⚙️
Le script "_Script_install_total" propose d'executer les scripts ci dessous.

Lors de son lancement manuel il créera un raccourci dans le dossier Startup afin de s'éxécuter apres chaque rédémarrage.
📍 Press "9" pour annuler cet option.


1️⃣ 1-Name&group : Renomme le poste, propose de rejoindre un domaine si nécessaire & vérifie l'adresse IP de la machine

2️⃣2-DC_creation : Installation d'un DC et promotion en tant que contrôleur

3️⃣3-import_user : pour un import user depuis un fichier CSV vers un AD 


#
Merci de penser au pôce bleu 👍

✨✨✨

Spécial dédicace à la chauve-souris haricot

👇👇

🦃🦃 

(avec de l'imagination ça passe)
