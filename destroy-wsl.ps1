param(
    [string]$MachineName
)

$confirm = Read-Host "Destroy ${MachineName}? This deletes everything. [y/N]"
if ($confirm -ne "y") { exit }

Write-Host "Terminating WSL instance..."
wsl --terminate $MachineName

Write-Host "Unregistering distro..."
wsl --unregister $MachineName

Write-Host "Done."
