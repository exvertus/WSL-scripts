param(
    [string]$RootFSUrl = "https://cloud-images.ubuntu.com/wsl/releases/24.04/current/ubuntu-noble-wsl-amd64-24.04lts.rootfs.tar.gz",
    [string]$DownloadPath = "C:\WSL\Images",
    [string]$MachinePath = "C:\WSL\Machines",
    [string]$MachineName = "TestMachine",
    [string]$DefaultUser = "dev"
)

if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Error "WSL not installed"
    exit 1
}

$uri = [System.Uri]$RootFSUrl
$rootfsFileName = Split-Path $uri.AbsolutePath -Leaf
$rootfsFile = Join-Path $DownloadPath $rootfsFileName
$machineDir = Join-Path $MachinePath $MachineName

New-Item -ItemType Directory -Force -Path $DownloadPath | Out-Null

if (!(Test-Path $rootfsFile)) {
    Write-Host "=== Downloading RootFS ==="
    try {
        Invoke-WebRequest `
          -Uri $RootFSUrl `
          -OutFile $rootfsFile `
          -UseBasicParsing `
          -ErrorAction Stop
    } catch {
        Write-Error "Download failed"
        exit 1
    }
}
else {
    Write-Host "RootFS already exists - skipping download"
}

New-Item -ItemType Directory -Force -Path $MachinePath | Out-Null
Write-Host "Using machine path $machineDir"

Write-Host "=== Importing WSL Distro ==="
$existing = wsl -l -q | Where-Object { $_ -eq $MachineName }
if ($existing) {
    Write-Error "WSL machine '$MachineName' already exists"
    Write-Error "Launch using: wsl -d $MachineName"
    exit 1
}
wsl --import $MachineName $machineDir $rootfsFile
if ($LASTEXITCODE -ne 0) {
    Write-Error "WSL import failed"
    exit 1
}

Write-Host "=== Provisioning Linux Environment ==="

# Use temp script to get around string-formatting issues
$tempScript = Join-Path $env:TEMP "wsl-provision.sh"

$bashScript = @"
set -e

echo "=== Creating user ==="
adduser --disabled-password --gecos "" $DefaultUser
usermod -aG sudo $DefaultUser

echo "$DefaultUser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$DefaultUser
chmod 440 /etc/sudoers.d/$DefaultUser

echo "=== Enabling systemd and default user ==="
cat > /etc/wsl.conf <<EOF
[boot]
systemd=true

[user]
default=$DefaultUser
EOF

"@

$bashScript = $bashScript -replace "`r",""

[System.IO.File]::WriteAllText(
    $tempScript,
    $bashScript,
    (New-Object System.Text.UTF8Encoding $false)
)

$tempScript = (Resolve-Path $tempScript).Path

$drive = $tempScript.Substring(0,1).ToLower()
$rest = $tempScript.Substring(2) -replace '\\','/'
$wslScriptPath = "/mnt/$drive/$rest"

wsl -d $MachineName -u root -- bash "$wslScriptPath"

Remove-Item $tempScript

Write-Host "=== Shutting down WSL to apply config ==="
wsl --terminate $MachineName

Write-Host "=== Setup complete ==="
Write-Host "Launch using: wsl -d $MachineName"

$answer = Read-Host "Do you want to launch now? [Y/n]"
if ($answer -eq "" -or $answer.ToLower() -eq "y") {
    wsl -d $MachineName
}
