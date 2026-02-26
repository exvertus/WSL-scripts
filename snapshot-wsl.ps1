param(
    [string]$MachineName = "TestMachine",
    [string]$BackupPath = "C:\WSL\Backups",
    [string]$BackupName
)

if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Error "WSL not installed"
    exit 1
}

$existing = wsl -l -q | Where-Object { $_ -eq $MachineName }
if (!$existing) {
    Write-Error "WSL machine '$MachineName' does not exist"
    exit 1
}

New-Item -ItemType Directory -Force -Path $BackupPath | Out-Null

if (!$BackupName) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $BackupName = "$MachineName-$timestamp.tar"
}

$backupFile = Join-Path $BackupPath $BackupName

Write-Host "=== Stopping Machine ==="
wsl --terminate $MachineName

Write-Host "=== Exporting snapshot ==="
wsl --export $MachineName $backupFile

if ($LASTEXITCODE -ne 0) {
    Write-Error "Snapshot failed"
    exit 1
}

Write-Host "=== Snapshot complete ==="
Write-Host "Saved to: $backupFile"
