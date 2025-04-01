# Demande les informations de base
$NewComputerName = Read-Host "Entrez le nouveau nom du poste (laisser vide pour ne pas changer)"
$JoinDomain = Read-Host "Voulez-vous rejoindre un domaine ? (O/N)"

# Vérifier et renommer l'ordinateur si nécessaire
if ($NewComputerName -and $env:COMPUTERNAME -ne $NewComputerName) {
    Write-Host "Renommage du poste en $NewComputerName..."
    Rename-Computer -NewName $NewComputerName -Force
}

# Vérifier si l'ordinateur est déjà membre d'un domaine
$CurrentDomain = (Get-WmiObject Win32_ComputerSystem).Domain
if ($CurrentDomain -eq $env:COMPUTERNAME -and $JoinDomain -match "[Oo]") {
    $DomainName = Read-Host "Entrez le nom du domaine (ex: mondomaine.local)"
    $User = Read-Host "Entrez un compte autorisé pour l'ajout au domaine (ex: Administrateur)"
    $Password = Read-Host "Entrez le mot de passe de $User" -AsSecureString

    # Tenter de joindre le domaine
    try {
        Add-Computer -DomainName $DomainName -Credential (New-Object PSCredential "$DomainName\$User", $Password) -Force
        Write-Host "L'ordinateur a été ajouté au domaine."
    } catch {
        Write-Host "Échec de l'ajout au domaine. Vérifiez les informations et les permissions."
    }
} else {
    Write-Host "L'ordinateur est déjà dans un domaine ou l'ajout a été annulé."
}

# Pause avant redémarrage forcé
Write-Host "`nAppuyez sur une touche pour redémarrer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Restart-Computer -Force
