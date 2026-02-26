param(
    [string]$MachineName = "TestMachine",
    [string]$MachinePath = "C:\WSL\Machines",
    [string]$BackupFile
)

if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Error "WSL not installed"
    exit 1
}

if (!(Test-Path $BackupFile)) {
    Write-Error "Backup file not found: $BackupFile"
    exit 1
}

$existing = wsl -l -q | Where-Object { $_ -eq $MachineName }
if ($existing) {
    Write-Error "Machine '$MachineName' already exists"
    exit 1
}

$machineDir = Join-Path $MachinePath $MachineName

Write-Host "=== Importing snapshot ==="
wsl --import $MachineName $machineDir $BackupFile

if ($LASTEXITCODE -ne 0) {
    Write-Error "Restore failed"
    exit 1
}

Write-Host "=== Restore complete ==="
Write-Host "Launch using: wsl -d $MachineName"

$answer = Read-Host "Launch machine now? [Y/n]"
if ($answer -eq "" -or $answer.ToLower() -eq "y") {
    wsl -d $MachineName
}
