# Menu de sélection
do {
    Clear-Host
    Write-Host "Que voulez-vous faire ?"
    Write-Host "1 - Créer des OU"
    Write-Host "2 - Importer des utilisateurs"
    Write-Host "3 - Quitter"
    $Choice = Read-Host "Entrez votre choix (1/2/3)"

    switch ($Choice) {
        1 { 
            # ==== CRÉATION DES OUs ====
            Write-Host "`n--- Création des OUs ---"

            # Vérifier si "ous.csv" est présent dans le dossier du script
            $ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
            $DefaultCsvPath = "$ScriptPath\ous.csv"

            if (Test-Path $DefaultCsvPath) {
                $UseDefault = Read-Host "Un fichier 'ous.csv' a été détecté. Voulez-vous l'utiliser ? (oui/non)"
                if ($UseDefault -match "[Oo]") {
                    $CsvPath = $DefaultCsvPath
                } else {
                    $CsvPath = Read-Host "Entrez le chemin du fichier CSV des OU"
                }
            } else {
                $CsvPath = Read-Host "Entrez le chemin du fichier CSV des OU"
            }

            # Vérifier le module ActiveDirectory
            if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
                Write-Host "Le module ActiveDirectory n'est pas installé."
                exit 1
            }
            Import-Module ActiveDirectory

            # Vérifier l'existence du fichier CSV
            if (-not (Test-Path $CsvPath)) {
                Write-Host "Le fichier CSV spécifié n'existe pas."
                exit 1
            }

            $ous = Import-Csv -Path $CsvPath

            # Création des OUs
            foreach ($ou in $ous) {
                $OUName = $ou.OUName
                $ParentOU = $ou.ParentOU
                $OUPath = "OU=$OUName,$ParentOU"

                # Vérifier si l'OU existe déjà
                $existingOU = Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $OUPath } -ErrorAction SilentlyContinue
                if ($existingOU) {
                    Write-Host "L'OU $OUName existe déjà."
                } else {
                    try {
                        New-ADOrganizationalUnit -Name $OUName -Path $ParentOU -ProtectedFromAccidentalDeletion $true
                        Write-Host "OU $OUName créée avec succès dans $ParentOU."
                    } catch {
                        Write-Host "Erreur lors de la création de l'OU $OUName."
                    }
                }
            }

            Write-Host "Création des OUs terminée.`n"
            Pause
        }

        2 {
            # ==== IMPORT DES UTILISATEURS ====
            Write-Host "`n--- Import des utilisateurs ---"

            # Vérifier si "users.csv" est présent dans le dossier du script
            $ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
            $DefaultCsvPath = "$ScriptPath\users.csv"

            if (Test-Path $DefaultCsvPath) {
                $UseDefault = Read-Host "Un fichier 'users.csv' a été détecté. Voulez-vous l'utiliser ? (oui/non)"
                if ($UseDefault -match "[Oo]") {
                    $CsvPath = $DefaultCsvPath
                } else {
                    $CsvPath = Read-Host "Entrez le chemin du fichier CSV des utilisateurs"
                }
            } else {
                $CsvPath = Read-Host "Entrez le chemin du fichier CSV des utilisateurs"
            }

            $TargetOU = Read-Host "Entrez l'OU cible dans Active Directory"
            $DryRun = Read-Host "Exécuter en mode simulation ? (oui/non)"
            $DryRun = $DryRun -match "[Oo]"

            # Mot de passe par défaut
            $defaultPassword = "P@ssw0rd123"

            # Vérification du module ActiveDirectory
            if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
                Write-Host "Le module ActiveDirectory n'est pas installé."
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
                Write-Host "Mode simulation activé. Aucune modification ne sera faite."
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
                        Write-Host "[Simulation] Création de : $fullName ($username) avec email : $email dans l'OU : $TargetOU"
                    } else {
                        try {
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
                        } catch {
                            Write-Host "Erreur lors de la création de $fullName."
                        }
                    }
                }
            }

            Write-Host "Import des utilisateurs terminé.`n"
            Pause
        }

        3 {
            Write-Host "Sortie du script."
            exit
        }

        default {
            Write-Host "Choix invalide, veuillez entrer 1, 2 ou 3."
        }
    }

} while ($true)
