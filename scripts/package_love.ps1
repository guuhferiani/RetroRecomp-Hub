# ==============================================================================
# RetroRecomp Hub - Local .love Packager
# Gera o arquivo RetroRecompHub.love para abrir direto no LÖVE do PC ou Android
# ==============================================================================

$hubDir = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $hubDir "dist"
$outFile = Join-Path $outDir "RetroRecompHub.love"

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

if (Test-Path $outFile) {
    Remove-Item -Force $outFile
}

Write-Host "[PACKAGER] Compactando RetroRecomp Hub para .love..." -ForegroundColor Cyan

# Arquivos a incluir no payload
$filesToZip = @(
    (Join-Path $hubDir "conf.lua"),
    (Join-Path $hubDir "main.lua"),
    (Join-Path $hubDir "README.md"),
    (Join-Path $hubDir "LICENSE"),
    (Join-Path $hubDir "src"),
    (Join-Path $hubDir "mods"),
    (Join-Path $hubDir "assets")
)

# Criar ZIP temporário e renomear para .love
$tempZip = Join-Path $outDir "temp_package.zip"
if (Test-Path $tempZip) { Remove-Item -Force $tempZip }

Compress-Archive -Path $filesToZip -DestinationPath $tempZip -CompressionLevel Optimal
Rename-Item -Path $tempZip -NewName "RetroRecompHub.love"

Write-Host "[SUCCESS] Pacote gerado com sucesso em:" -ForegroundColor Green
Write-Host "  $outFile" -ForegroundColor Yellow
Write-Host "Voce pode transferir esse arquivo para seu celular e abrir com o app LOVE for Android!" -ForegroundColor Gray
