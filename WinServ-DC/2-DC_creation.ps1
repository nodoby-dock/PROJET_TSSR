# Vérifier si la machine est déjà membre d'un domaine
$CurrentDomain = (Get-WmiObject Win32_ComputerSystem).Domain

if ($CurrentDomain -eq $env:COMPUTERNAME) {
    Write-Host "Aucun domaine trouvé, création d'un nouveau domaine..."
    $NewDomain = $true
} else {
    Write-Host "La machine semble déjà dans un domaine ($CurrentDomain), vérification des DC existants..."
    try {
        $DCs = Get-ADDomainController -ErrorAction Stop
        $NewDomain = $false
    } catch {
        Write-Host "Impossible de contacter un DC, création d'un nouveau domaine..."
        $NewDomain = $true
    }
}

# Si aucun DC n'existe, on crée un nouveau domaine
if ($NewDomain) {
    $DomainName = Read-Host "Entrez le nom de domaine (ex: mondomaine.local)"
    $NetBiosName = Read-Host "Entrez le nom NetBIOS du domaine (ex: MONDOMAINE)"
    
    # Vérification du mot de passe admin
    do {
        $SafeModePassword = Read-Host "Entrez le mot de passe du mode sans échec AD (Doit être fort)" -AsSecureString
        $ConfirmPassword = Read-Host "Confirmez le mot de passe" -AsSecureString
        
        if (-not (Compare-SecureString $SafeModePassword $ConfirmPassword)) {
            Write-Host "Les mots de passe ne correspondent pas. Veuillez réessayer." -ForegroundColor Red
        }
    } while (-not (Compare-SecureString $SafeModePassword $ConfirmPassword))

    # Installation du rôle ADDS
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

    # Création du domaine
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBiosName `
        -SafeModeAdministratorPassword $SafeModePassword `
        -InstallDNS `
        -Force
} else {
    Write-Host "Ajout en tant que DC secondaire dans le domaine $CurrentDomain..."
    
    Install-ADDSDomainController `
        -DomainName $CurrentDomain `
        -SafeModeAdministratorPassword $SafeModePassword `
        -InstallDNS `
        -Force
}

# Redémarrage après installation
Write-Host "Installation terminée. Redémarrage en cours..."
Restart-Computer -Force

# Fonction pour comparer deux SecureString
function Compare-SecureString($String1, $String2) {
    return (New-Object PSCredential "user", $String1).GetNetworkCredential().Password -eq `
           (New-Object PSCredential "user", $String2).GetNetworkCredential().Password
}
