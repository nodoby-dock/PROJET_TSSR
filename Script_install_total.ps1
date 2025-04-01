# Menu principal
function Show-Menu {
    Clear-Host
    Write-Host "============================================="
    Write-Host " Bienvenue dans la préparation du serveur "
    Write-Host "============================================="
    Write-Host "1 - Changement du nom et/ou rejoindre un domaine"
    Write-Host "2 - Installation d'un contrôleur de domaine (DC)"
    Write-Host "3 - Option supplémentaire (placeholder)"
    Write-Host "..."
    Write-Host "0 - Quitter"
    Write-Host "============================================="
}

do {
    Show-Menu
    $choice = Read-Host "Choisissez une option (1-3 ou 0 pour quitter)"

    switch ($choice) {
        "1" {
            Write-Host "Exécution du script de renommage et d'ajout au domaine..."
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File .\Name&group.ps1" -NoNewWindow -Wait
        }
        "2" {
            Write-Host "Exécution du script d'installation du contrôleur de domaine..."
            Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File .\DC_creation.ps1" -NoNewWindow -Wait
        }
        "3" {
            Write-Host "Fonctionnalité à implémenter..."
            Start-Sleep 2
        }
        "0" {
            Write-Host "Quitter..."
            break
        }
        default {
            Write-Host "Option invalide, veuillez choisir une option valide."
        }
    }
} while ($true)
