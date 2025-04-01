param (
    [string]$CsvPath,        # Chemin vers le fichier CSV
    [string]$TargetOU,       # OU cible dans Active Directory
    [switch]$DryRun          # Mode de simulation sans modification réelle
)

# Mot de passe par défaut
$defaultPassword = "P@ssw0rd123"  # Vous pouvez ajuster ce mot de passe par défaut

# Vérification que le module ActiveDirectory est chargé
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Le module ActiveDirectory n'est pas installé ou chargé. Veuillez installer le module."
    exit 1
}

# Importer le module ActiveDirectory
Import-Module ActiveDirectory

# Lire les utilisateurs à partir du fichier CSV
if (-not (Test-Path $CsvPath)) {
    Write-Host "Le fichier CSV spécifié n'existe pas."
    exit 1
}

$users = Import-Csv -Path $CsvPath

# Afficher un résumé des utilisateurs à créer
Write-Host "Utilisateurs à créer :"
$users | ForEach-Object { Write-Host "$($_.FirstName) $($_.LastName)" }

# Si le mode DryRun est activé, simuler les créations sans effectuer les actions
if ($DryRun) {
    Write-Host "Mode DryRun activé. Les utilisateurs ne seront pas réellement créés."
} else {
    Write-Host "Ajout des utilisateurs dans Active Directory..."
}

# Parcourir chaque utilisateur et créer un objet dans Active Directory
foreach ($user in $users) {
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $username = ($firstName.Substring(0,1) + $lastName).ToLower()  # Générer le nom d'utilisateur : 1ère lettre prénom + nom
    $email = ($firstName.Substring(0,1) + $lastName + "@mail.com").ToLower()  # Générer l'email
    $password = ConvertTo-SecureString -AsPlainText $defaultPassword -Force
    $fullName = "$firstName $lastName"

    # Vérifier si l'utilisateur existe déjà dans Active Directory
    $existingUser = Get-ADUser -Filter {SamAccountName -eq $username} -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "L'utilisateur $username existe déjà. Passer à l'utilisateur suivant."
    } else {
        # Création de l'utilisateur dans Active Directory
        if ($DryRun) {
            Write-Host "[DryRun] Créer l'utilisateur : $fullName ($username) avec email : $email dans l'OU : $TargetOU"
        } else {
            New-ADUser `
                -SamAccountName $username `
                -UserPrincipalName $email `
                -Name $fullName `
                -GivenName $firstName `
                -Surname $lastName `
                -DisplayName "$firstName $lastName" `
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