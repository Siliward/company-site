param(
    [string]$HostAlias = "siliward",
    [string]$RemoteUser = "root",
    [string]$RemoteDir = "/var/www/siliward.com",
    [string]$BackupBaseDir = "/root/deploy-backups/siliward.com",
    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot "dist"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$remoteStagingDir = "/home/$RemoteUser/deploy-staging/siliward.com/$stamp"
if ($RemoteUser -eq "root") {
    $remoteStagingDir = "/root/deploy-staging/siliward.com/$stamp"
}
$remoteReleaseDir = "/var/www/.siliward-release-$stamp"
$remoteBackupDir = "$BackupBaseDir/$stamp"
$localTempDir = Join-Path ([System.IO.Path]::GetTempPath()) "siliward-deploy-$stamp"
$localArchivePath = Join-Path $localTempDir "site.tar"
$localRemoteScriptPath = Join-Path $localTempDir "remote-deploy.sh"
$remoteArchivePath = "$remoteStagingDir/site.tar"
$remoteScriptPath = "/tmp/siliward-remote-deploy-$stamp.sh"

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    Write-Host "==> $Message"
    & $Action
}

if (-not $SkipBuild) {
    Invoke-Step "Building site" {
        & npm run build
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed."
        }
    }
}

if (-not (Test-Path $distDir)) {
    throw "Build output not found: $distDir"
}

Invoke-Step "Preparing local temp directory" {
    New-Item -ItemType Directory -Path $localTempDir -Force | Out-Null
}

Invoke-Step "Preparing remote staging directory" {
    & ssh $HostAlias "mkdir -p '$remoteStagingDir'"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to prepare remote staging directory."
    }
}

Invoke-Step "Creating deployment archive" {
    & tar -C $distDir -cf $localArchivePath .
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create deployment archive."
    }
}

Invoke-Step "Uploading deployment archive" {
    & scp $localArchivePath "${HostAlias}:$remoteArchivePath"
    if ($LASTEXITCODE -ne 0) {
        throw "Archive upload failed."
    }
}

Invoke-Step "Extracting archive into remote staging" {
    & ssh $HostAlias "tar -xf '$remoteArchivePath' -C '$remoteStagingDir' && rm -f '$remoteArchivePath'"
    if ($LASTEXITCODE -ne 0) {
        throw "Remote archive extraction failed."
    }
}

$remoteDeployScript = @"
set -euo pipefail

target_dir='$RemoteDir'
staging_dir='$remoteStagingDir'
release_dir='$remoteReleaseDir'
backup_dir='$remoteBackupDir'

if [ "`$target_dir" != "/var/www/siliward.com" ]; then
  echo "Refusing to deploy to unexpected target: `$target_dir" >&2
  exit 1
fi

if [ ! -d "`$staging_dir" ]; then
  echo "Missing staging directory: `$staging_dir" >&2
  exit 1
fi

mkdir -p "`$(dirname "`$release_dir")" "`$(dirname "`$target_dir")" "$BackupBaseDir"
rsync -a --delete "`$staging_dir/" "`$release_dir/"
chown -R zjwei:zjwei "`$release_dir"
find "`$release_dir" -type d -exec chmod 755 {} \;
find "`$release_dir" -type f -exec chmod 644 {} \;

if [ -e "`$target_dir" ]; then
  mv "`$target_dir" "`$backup_dir"
fi

mv "`$release_dir" "`$target_dir"
rm -rf "`$staging_dir"

echo "Deployment complete."
echo "Active: `$target_dir"
echo "Backup: `$backup_dir"
"@

Invoke-Step "Uploading remote deploy script" {
    Set-Content -Path $localRemoteScriptPath -Value $remoteDeployScript -NoNewline
    & scp $localRemoteScriptPath "${HostAlias}:$remoteScriptPath"
    if ($LASTEXITCODE -ne 0) {
        throw "Remote deploy script upload failed."
    }
}

Invoke-Step "Switching live site on remote host" {
    & ssh -t $HostAlias "bash '$remoteScriptPath' && rm -f '$remoteScriptPath'"
    if ($LASTEXITCODE -ne 0) {
        throw "Remote deployment failed."
    }
}

Invoke-Step "Cleaning up local temp files" {
    Remove-Item -LiteralPath $localTempDir -Recurse -Force
}

Write-Host ""
Write-Host "Deploy finished successfully."
Write-Host "Host:   $HostAlias"
Write-Host "Target: $RemoteDir"
Write-Host "Backup: $remoteBackupDir"
