# Demander les entrées 
$CsvPath = Read-Host "Entrez le chemin du fichier CSV"
$TargetOU = Read-Host "Entrez l'OU cible dans Active Directory"
$DryRun = Read-Host "Exécuter en mode simulation ? (oui/non)"
$DryRun = $DryRun -eq "oui"

# Mot de passe par défaut
$defaultPassword = "P@ssw0rd123"

# Vérification du module ActiveDirectory
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Le module ActiveDirectory n'est pas installé ou chargé. Veuillez l'installer."
    exit 1
}

Import-Module ActiveDirectory

# Vérifier l'existence du fichier CSV
if (-not (Test-Path $CsvPath)) {
    Write-Host "Le fichier CSV spécifié n'existe pas."
    exit 1
}

$users = Import-Csv -Path $CsvPath

# Afficher les utilisateurs 
Write-Host "Utilisateurs à créer :"
$users | ForEach-Object { Write-Host "$($_.FirstName) $($_.LastName)" }

if ($DryRun) {
    Write-Host "Mode DryRun activé. Les utilisateurs ne seront pas créés."
} else {
    Write-Host "Ajout des utilisateurs dans Active Directory..."
}

foreach ($user in $users) {
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $username = ($firstName.Substring(0,1) + $lastName).ToLower()
    $email = "$username@mail.com"
    $password = ConvertTo-SecureString -AsPlainText $defaultPassword -Force
    $fullName = "$firstName $lastName"

    $existingUser = Get-ADUser -Filter {SamAccountName -eq $username} -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "L'utilisateur $username existe déjà."
    } else {
        if ($DryRun) {
            Write-Host "[DryRun] Créer l'utilisateur : $fullName ($username) avec email : $email dans l'OU : $TargetOU"
        } else {
            New-ADUser `
                -SamAccountName $username `
                -UserPrincipalName $email `
                -Name $fullName `
                -GivenName $firstName `
                -Surname $lastName `
                -DisplayName "$fullName" `
                -EmailAddress $email `
                -AccountPassword $password `
                -Enabled $true `
                -PassThru `
                -Path $TargetOU

            Write-Host "Utilisateur $fullName créé avec succès."
        }
    }
}

Write-Host "Script terminé."
