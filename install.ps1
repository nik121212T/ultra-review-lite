# Usage: irm https://raw.githubusercontent.com/nik121212T/ultra-review-lite/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$dest = "$env:USERPROFILE\.claude\skills"
$tmp = "$env:TEMP\my-claude-skills-install"

Write-Host "Installing custom Claude skills..."
New-Item -ItemType Directory -Force -Path $dest | Out-Null

if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
git clone --depth=1 https://github.com/nik121212T/ultra-review-lite.git $tmp

Get-ChildItem $tmp -Directory | ForEach-Object {
    $name = $_.Name
    if (Test-Path "$dest\$name") {
        Write-Host "  update: $name"
    } else {
        Write-Host "  install: $name"
    }
    Copy-Item $_.FullName -Destination $dest -Recurse -Force
}

Remove-Item $tmp -Recurse -Force
Write-Host "Done. Restart Claude Code to load new skills."
