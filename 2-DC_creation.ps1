# Affichage du nom actuel du serveur
Write-Host "Nom actuel du serveur : $env:COMPUTERNAME"
$ConfirmName = Read-Host "Le nom est-il correct ? (O/N)"

# Si le nom n'est pas correct, demander un nouveau nom
if ($ConfirmName -match "[Nn]") {
    $ServerName = Read-Host "Entrez le nouveau nom du serveur"
    Write-Host "Renommage du serveur en $ServerName..."
    Rename-Computer -NewName $ServerName -Force
    Write-Host "Renommage terminé. Redémarrage en cours..."
    Restart-Computer -Force
    exit
}

# Demande des informations pour le domaine
$DomainName = Read-Host "Entrez le nom de domaine (ex: mondomaine.local)"
$NetBiosName = Read-Host "Entrez le nom NetBIOS du domaine (ex: MONDOMAINE)"
$SafeModePassword = Read-Host "Entrez le mot de passe du mode sans échec AD (Doit être fort)" -AsSecureString

# Vérifier si le module ADDSDeployment est disponible
if (-not (Get-Module -ListAvailable -Name ADDSDeployment)) {
    Write-Host "Le module ADDSDeployment est introuvable. Installation du rôle ADDS..."
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
}

# Vérifier si un contrôleur de domaine existe déjà dans le réseau
$DCs = Get-ADDomainController -ErrorAction SilentlyContinue

if ($DCs) {
    Write-Host "Un contrôleur de domaine existe déjà. Ajout en tant que DC supplémentaire..."
    Install-ADDSDomainController `
        -DomainName $DomainName `
        -SafeModeAdministratorPassword $SafeModePassword `
        -InstallDNS `
        -Force
} else {
    Write-Host "Aucun DC trouvé. Création d'un nouveau domaine..."
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBiosName `
        -SafeModeAdministratorPassword $SafeModePassword `
        -InstallDNS `
        -Force
}

# Redémarrer après installation
Write-Host "Installation terminée. Redémarrage en cours..."
Restart-Computer -Force