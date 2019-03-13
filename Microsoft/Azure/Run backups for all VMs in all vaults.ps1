$AzureVaults = Get-AzureRmRecoveryServicesVault

foreach ($AzureVault in $AzureVaults) {
    $InProgressBackupContainers = [System.Collections.Arraylist]@((Get-AzureRmRecoveryServicesBackupJob -VaultId $AzureVault.Id  -status "InProgress").WorkLoadName)
    $Containers = Get-AzureRmRecoveryServicesBackupContainer -VaultId $AzureVault.Id -ContainerType "AzureVM"

    foreach ($Container in $Containers) {
        if (-not ($Container.friendlyname | Where-Object { $InProgressBackupContainers -ilike $_ })) {
            $ContainerObject = Get-AzureRmRecoveryServicesBackupContainer -VaultId $AzureVault.Id -ContainerType "AzureVM" -FriendlyName $Container.FriendlyName
            $BackupItem = Get-AzureRmRecoveryServicesBackupItem -VaultId $AzureVault.Id -Container $ContainerObject -WorkloadType "AzureVM"
            Backup-AzureRmRecoveryServicesBackupItem -VaultId $AzureVault.Id -Item $BackupItem
        }
        Else {
            Write-output "$($Container.Friendlyname) is already being backed up. Skipping....."
        }
    }
}