function Ensure-OUPath {
    param (
        [string]$FullPath
    )

    # Si l'OU existe déjà, on ne fait rien
    if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$FullPath)" -ErrorAction SilentlyContinue) {
        return
    }

    # On coupe le chemin en morceaux (en partant du plus bas)
    $components = $FullPath -split '(?<!\\),'
    $dnList = @()

    for ($i = $components.Length - 1; $i -ge 0; $i--) {
        $dn = ($components[$i..($components.Length - 1)] -join ',')

        # On ne traite que les DN qui commencent par "OU="
        if ($dn -like 'OU=*') {
            $dnList += $dn
        }
    }

    # On part du haut vers le bas
    foreach ($dn in ($dnList | Sort-Object Length)) {
        if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$dn)" -ErrorAction SilentlyContinue)) {
            $ouName = ($dn -split '(?<!\\),')[0] -replace '^OU='
            $ouPath = ($dn -replace '^OU=[^,]+,')  # retire le premier segment pour obtenir le parent

            try {
                New-ADOrganizationalUnit -Name $ouName -Path $ouPath -ProtectedFromAccidentalDeletion $true
                Write-Host "OU $dn créée avec succès." -ForegroundColor Green
            } catch {
                Write-Host "Erreur lors de la création de l'OU $dn. Détails : $_" -ForegroundColor Red
            }
        }
    }
}

# === MENU PRINCIPAL ===
do {
    Clear-Host
    Write-Host "Que voulez-vous faire ?"
    Write-Host "1 - Créer des OU"
    Write-Host "2 - Importer des utilisateurs"
    Write-Host "3 - Quitter"
    $Choice = Read-Host "Entrez votre choix (1/2/3)"

    switch ($Choice) {
        1 {
            Write-Host "`n--- Création des OUs ---"

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

            if (-not (Test-Path $CsvPath)) {
                Write-Host "Le fichier CSV spécifié n'existe pas." -ForegroundColor Red
                exit 1
            }

            if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
                Write-Host "Le module Active Directory n'est pas installé." -ForegroundColor Red
                exit 1
            }
            Import-Module ActiveDirectory

            $DryRun = Read-Host "Exécuter en mode simulation ? (oui/non)"
            $DryRun = $DryRun -match "[Oo]"

            $ous = Import-Csv -Path $CsvPath

            foreach ($ou in $ous) {
                $OUName = $ou.OUName
                $ParentOU = $ou.ParentOU
                $OUPath = "OU=$OUName,$ParentOU"

                if ($DryRun) {
                    Write-Host "[Simulation] Création de l'OU : $OUPath" -ForegroundColor Cyan
                } else {
                    Ensure-OUPath -FullPath $OUPath
                }
            }

            Write-Host "Création des OUs terminée.`n"
            Pause
        }

        2 {
            Write-Host "`n--- Import des utilisateurs ---"

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

            $defaultPassword = "P@ssw0rd123"

            if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
                Write-Host "Le module Active Directory n'est pas installé." -ForegroundColor Red
                exit 1
            }
            Import-Module ActiveDirectory

            if (-not (Test-Path $CsvPath)) {
                Write-Host "Le fichier CSV spécifié n'existe pas." -ForegroundColor Red
                exit 1
            }

            $users = Import-Csv -Path $CsvPath

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

                $existingUser = Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue

                if ($existingUser) {
                    Write-Host "L'utilisateur $username existe déjà." -ForegroundColor Yellow
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
                                -Path $TargetOU

                            Write-Host "Utilisateur $fullName créé avec succès." -ForegroundColor Green
                        } catch {
                            Write-Host "Erreur lors de la création de $fullName. Détails : $_" -ForegroundColor Red
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
