# WSL Scripts

PowerShell scripts to automate WSL and use it like a disposable, snapshot-capable VM system.

### Prerequisites

- Windows with WSL installed
- WSL2 enabled
- PowerShell
- Internet access (for RootFS downloads)

Verify WSL is installed:

```powershell
wsl --status
```

#### Typical workflow example:

Create machine:
```powershell
.\create-wsl.ps1 -MachineName TestVM
```

Start/resume the machine:
```powershell
wsl -d TestVM
```

Stop machine:
```powershell
wsl --terminate TestVM
```

Create portable snapshot .tar:
```powershell
.\snapshot-wsl.ps1 -MachineName TestVM -BackupName TestVMBackup.tar
```

Destroy and unregister:
```powershell
.\destroy-wsl.ps1 -MachineName TestVM
```

Restore from .tar:
```powershell
.\restore-wsl.ps1 -MachineName TestVM -BackupFile C:\WSL\Backups\TestVMBackup.tar
```

### Terminology

- **RootFS**: a base starting Linux filesystem, in the form of a .tar.gz, used to create a new WSL machine.
- **Machine**: a registered WSL environment with its own filesystem and configuration (called 'distributions' by WSL docs)
- **Backup**: a portable snapshot, in the form of a .tar archive, of an existing WSL machine, including installed software, that survives destruction.
- **DownloadPath**: where RootFS files are stored. Defaults to `C:\WSL\Images`.
- **MachinePath**: where registered WSL disks (ext4.vhdx files) are stored. Defaults to `C:\WSL\Machines`.
- **BackupPath**: where portable backup snapshot files (.tar) are stored. Defaults to `C:\WSL\Backups`.

### Verbose script-call examples

Create a new WSL machine:

```powershell
.\create-wsl.ps1 `
  -MachineName MyWSLMachine `
  -RootFSUrl https://cloud-images.ubuntu.com/wsl/releases/24.04/current/ubuntu-noble-wsl-amd64-24.04lts.rootfs.tar.gz `
  -DownloadPath C:\WSL\Images `
  -MachinePath C:\WSL\Machines `
  -DefaultUser dev
```

Export a WSL machine to a .tar backup (survives a destroy):

```powershell
.\snapshot-wsl.ps1 `
  -MachineName MyWSLMachine `
  -BackupPath C:\WSL\Backups `
  -BackupName MyWSLBackup.tar
```

Restore a WSL machine from a .tar backup:

```powershell
.\restore-wsl.ps1 `
  -MachineName MyWSLMachine `
  -MachinePath C:\WSL\Machines `
  -BackupFile C:\WSL\Backups\MyWSLBackup.tar
```

Destroy a WSL machine (permanently deletes the machine and its disk):

```powershell
.\destroy-wsl.ps1 `
  -MachineName MyWSLMachine
```

### Additional info

RootFSFiles can be found at [https://cloud-images.ubuntu.com/wsl/](https://cloud-images.ubuntu.com/wsl/)

WSL machines persist their filesystem automatically inside a virtual disk (ext4.vhdx).

The default user is created with passwordless sudo.

#### Default directory layout:

```
C:\WSL
├── Images
│ └── ubuntu.rootfs.tar.gz
├── Machines
│ └── MyWSLMachine
│   └── ext4.vhdx
└── Backups
  └── MyWSLBackup.tar
```
