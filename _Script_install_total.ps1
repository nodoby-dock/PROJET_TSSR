<<<<<<< HEAD
# Définition du chemin du raccourci de démarrage automatique
$StartupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\server_setup.lnk"

# Vérifier si le script est déjà en auto-lancement et le configurer si nécessaire
if (-not (Test-Path $StartupPath)) {
    Write-Host "Configuration du script pour qu'il démarre automatiquement..."
    
    # Création d'un raccourci vers le script dans le dossier de démarrage
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($StartupPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $Shortcut.WorkingDirectory = "$PSScriptRoot"
    $Shortcut.Save()
    
    Write-Host "Le script démarrera automatiquement au prochain redémarrage."
}

# Fonction pour afficher le menu
=======
# Menu principal
>>>>>>> 98165b8aeacff72baef04185a0b0fc7316885ebb
function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host " Bienvenue dans la préparation du serveur "
    Write-Host "============================================="
    Write-Host "1 - Changement du nom et/ou rejoindre un domaine"
    Write-Host "2 - Installation d'un contrôleur de domaine (DC)"
    Write-Host "3 - Option supplémentaire (placeholder)"
    Write-Host "..."
<<<<<<< HEAD
    Write-Host "9 - Désactiver l'exécution automatique au démarrage"
=======
>>>>>>> 98165b8aeacff72baef04185a0b0fc7316885ebb
    Write-Host "0 - Quitter"
    Write-Host "============================================="
}

do {
    Show-Menu
<<<<<<< HEAD
    $choice = Read-Host "Choisissez une option (1-3, 9 pour désactiver l'auto-lancement, 0 pour quitter)"
=======
    $choice = Read-Host "Choisissez une option (1-3 ou 0 pour quitter)"
>>>>>>> 98165b8aeacff72baef04185a0b0fc7316885ebb

    switch ($choice) {
        "1" {
            Write-Host "Exécution du script de renommage et d'ajout au domaine..."
<<<<<<< HEAD
<<<<<<< HEAD:_Script_install_total.ps1
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\1-Name&group.ps1`"" -NoNewWindow -Wait
        }
        "2" {
            Write-Host "Exécution du script d'installation du contrôleur de domaine..."
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\2-DC_creation.ps1`"" -NoNewWindow -Wait
=======
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File .\1-Name&group.ps1" -NoNewWindow -Wait
        }
        "2" {
            Write-Host "Exécution du script d'installation du contrôleur de domaine..."
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File .\2-DC_creation.ps1" -NoNewWindow -Wait
=======
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\Name&group.ps1`"" -NoNewWindow -Wait
        }
        "2" {
            Write-Host "Exécution du script d'installation du contrôleur de domaine..."
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\DC_creation.ps1`"" -NoNewWindow -Wait
=======
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File .\Name&group.ps1" -NoNewWindow -Wait
        }
        "2" {
            Write-Host "Exécution du script d'installation du contrôleur de domaine..."
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File .\DC_creation.ps1" -NoNewWindow -Wait
>>>>>>> eec7dad05e4bea48f20d3ccdcfca8b2846d5a8ef:Script_install_total.ps1
>>>>>>> 98165b8aeacff72baef04185a0b0fc7316885ebb
        }
        "3" {
            Write-Host "Fonctionnalité à implémenter..."
            Start-Sleep 2
        }
<<<<<<< HEAD
        "9" {
            Write-Host "Désactivation de l'exécution automatique..."
            if (Test-Path $StartupPath) {
                Remove-Item $StartupPath -Force
                Write-Host "Le script ne se lancera plus automatiquement."
            } else {
                Write-Host "Le script n'était pas en démarrage automatique."
            }
            Start-Sleep 2
        }
        "0" {
            Write-Host "Fermeture du script..."
            Start-Sleep 1
            exit
        }
        default {
            Write-Host "Option invalide, veuillez choisir une option valide."
            Start-Sleep 2
=======
        "0" {
            Write-Host "Quitter..."
            break
        }
        default {
            Write-Host "Option invalide, veuillez choisir une option valide."
>>>>>>> 98165b8aeacff72baef04185a0b0fc7316885ebb
        }
    }
} while ($true)
