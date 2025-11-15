param([string]$OutFile="order-taking.zip")
$exclude = @('target','db_data','.git','.idea','.vscode','node_modules')
$items = Get-ChildItem -Force | Where-Object { $exclude -notcontains $_.Name }
if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
Compress-Archive -Path $items -DestinationPath $OutFile -Force
Write-Host "Created $OutFile"