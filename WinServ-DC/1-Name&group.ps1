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

# Vérifier si l'adresse IP est dynamique ou statique
$Interface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq "Up" }
if ($Interface) {
    if ($Interface.InterfaceAlias -and $Interface.DNSServer.ServerAddresses) {
        $Adapter = Get-NetAdapter -Name $Interface.InterfaceAlias
        $DhcpEnabled = (Get-NetIPInterface -InterfaceIndex $Adapter.ifIndex).Dhcp

        if ($DhcpEnabled -eq "Enabled") {
            Write-Host "L'adresse IP est configurée en DHCP."
            $SetStatic = Read-Host "Voulez-vous configurer une IP statique ? (O/N)"
            if ($SetStatic -match "[Oo]") {
                $IpAddress = Read-Host "Entrez l'adresse IP (ex: 192.168.1.100)"
                $SubnetMask = Read-Host "Entrez le masque de sous-réseau (ex: 255.255.255.0)"
                $Gateway = Read-Host "Entrez la passerelle (ex: 192.168.1.1)"
                $Dns = Read-Host "Entrez le(s) serveur(s) DNS séparés par une virgule (ex: 8.8.8.8,8.8.4.4)"
                
                try {
                    New-NetIPAddress -InterfaceIndex $Adapter.ifIndex -IPAddress $IpAddress -PrefixLength ($SubnetMask -split "\.")[0] -DefaultGateway $Gateway
                    Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses ($Dns -split ",")
                    Write-Host "Adresse IP configurée en statique avec succès."
                } catch {
                    Write-Host "Échec de la configuration de l'adresse IP statique."
                }
            }
        } else {
            $CurrentIP = ($Interface.IPv4Address).IPAddress
            Write-Host "L'adresse IP est déjà configurée en statique : $CurrentIP"
            $KeepStatic = Read-Host "Voulez-vous la garder ? (O/N)"
            if ($KeepStatic -match "[Nn]") {
                $IpAddress = Read-Host "Entrez la nouvelle adresse IP (ex: 192.168.1.100)"
                $SubnetMask = Read-Host "Entrez le masque de sous-réseau (ex: 255.255.255.0)"
                $Gateway = Read-Host "Entrez la passerelle (ex: 192.168.1.1)"
                $Dns = Read-Host "Entrez le(s) serveur(s) DNS séparés par une virgule (ex: 8.8.8.8,8.8.4.4)"
                
                try {
                    New-NetIPAddress -InterfaceIndex $Adapter.ifIndex -IPAddress $IpAddress -PrefixLength ($SubnetMask -split "\.")[0] -DefaultGateway $Gateway
                    Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses ($Dns -split ",")
                    Write-Host "Nouvelle adresse IP configurée avec succès."
                } catch {
                    Write-Host "Échec de la modification de l'adresse IP."
                }
            } else {
                Write-Host "L'adresse IP actuelle est conservée."
            }
        }
    } else {
        Write-Host "Impossible de détecter une connexion réseau active."
    }
} else {
    Write-Host "Aucune connexion réseau détectée."
}

# Pause avant redémarrage forcé
Write-Host "`nAppuyez sur une touche pour redémarrer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Restart-Computer -Force
