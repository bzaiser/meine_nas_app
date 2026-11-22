param(
    [string]$SshHost = ""
)
$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir
New-Item -ItemType Directory -Force -Path "$RootDir\dist" | Out-Null
$TarPath = "$RootDir\dist\meine_nas_app-image.tar"

if ($SshHost) {
    Write-Host "🌐 Baue Image meine_nas_app:latest per SSH auf Linux-VM ($SshHost)..." -ForegroundColor Cyan
    $RemoteTmp = "/tmp/build_meine_nas_app"
    ssh $SshHost "rm -rf $RemoteTmp && mkdir -p $RemoteTmp"
    scp Dockerfile requirements.txt entrypoint.sh manage.py "${SshHost}:${RemoteTmp}/"
    scp -r config apps templates "${SshHost}:${RemoteTmp}/"
    ssh $SshHost "cd $RemoteTmp && docker build --platform linux/amd64 -t meine_nas_app:latest . && docker save -o $RemoteTmp/meine_nas_app-image.tar meine_nas_app:latest"
    scp "${SshHost}:${RemoteTmp}/meine_nas_app-image.tar" $TarPath
    ssh $SshHost "rm -rf $RemoteTmp"
    Write-Host "✅ Image von Linux-VM gespeichert unter: $TarPath" -ForegroundColor Green
    Write-Host "   Auf dem NAS starten mit: ./docker/load-nas-image.sh"
    exit 0
}

if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker build --platform linux/amd64 -t "meine_nas_app:latest" .
    if (Test-Path $TarPath) { Remove-Item -Force $TarPath }
    docker save -o $TarPath "meine_nas_app:latest"
    Write-Host "✅ Fertig: $TarPath" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Kein lokaler Docker-Daemon unter Windows aktiv." -ForegroundColor Yellow
    Write-Host "Option A (empfohlen, 0 Sek. Build): App-Ordner direkt aufs NAS kopieren & ./docker/update-fast.sh starten (nutzt dort automatisch das vorhandene Baukasten-Basis-Image!)." -ForegroundColor Green
    Write-Host "Option B (Build über deine Linux-VM per SSH):" -ForegroundColor Cyan
    Write-Host "   .\docker\build-pc-image.ps1 -SshHost user@<linux-vm-ip>"
}
