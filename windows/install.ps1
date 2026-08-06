# wellutils installer (Windows)
# One-line install:
#   irm https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.ps1 | iex
# Requires Windows PowerShell 5.1+ (built-in) or PowerShell 7. No admin rights needed.
# Installs to:  %USERPROFILE%\.wellutils\bin\  (well.ps1 + well*.cmd shims)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$Repo = 'Wellbou/wellutils'
$Raw = if ($env:WELLUTILS_RAW) { $env:WELLUTILS_RAW } else { "https://raw.githubusercontent.com/$Repo" }
$Api = if ($env:WELLUTILS_API) { $env:WELLUTILS_API } else { "https://api.github.com/repos/$Repo" }

$Dest = Join-Path $HOME '.wellutils'
$Bin = Join-Path $Dest 'bin'
$PWS = Join-Path $Bin 'well.ps1'
$Tools = @('wellmem', 'wellhw', 'wellusb', 'wellpci', 'wellblock', 'wellmod', 'wellsensors', 'wellper', 'wellfetch')

function Get-WuSource {
    param([string]$Ver)
    $url = "$Raw/$Ver/windows/well.ps1"
    $tmpdir = if ($env:TEMP) { $env:TEMP } else { $env:TMP }
    if (-not $tmpdir) { $tmpdir = (Join-Path $HOME '.wellutils-tmp') }
    if (-not (Test-Path $tmpdir)) { New-Item -ItemType Directory -Force -Path $tmpdir | Out-Null }
    $tmp = Join-Path $tmpdir ("well-" + [Guid]::NewGuid().ToString('N') + ".ps1")
    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
    return $tmp
}

$tag = $null
try {
    $rel = Invoke-RestMethod -Uri "$Api/releases/latest" -Headers @{ 'User-Agent' = 'wellutils-installer' }
    $tag = $rel.tag_name
    if ($tag) { Write-Host "Found release: $tag" }
} catch { }

$src = $null
if ($tag) {
    try { $src = Get-WuSource $tag } catch { $src = $null; Write-Host "Release $tag not downloadable, falling back to main." }
}
if (-not $src) {
    Write-Host 'Using main branch.'
    $src = Get-WuSource 'main'
}

New-Item -ItemType Directory -Force -Path $Bin | Out-Null
Copy-Item -Path $src -Destination $PWS -Force
Remove-Item -Path $src -Force

$shim = @"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "$PWS" %*
"@
Set-Content -Path (Join-Path $Bin 'well.cmd') -Value $shim -Encoding Ascii
foreach ($t in $Tools) {
    $sh = @"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "$PWS" $t %*
"@
    Set-Content -Path (Join-Path $Bin "$t.cmd") -Value $sh -Encoding Ascii
}

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not $userPath) { $userPath = '' }
$parts = @($userPath -split ';' | Where-Object { $_ -ne '' })
if ($parts -notcontains $Bin) {
    $parts += $Bin
    [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')
    Write-Host "Added $Bin to user PATH."
} else {
    Write-Host 'PATH already contains the install dir.'
}

Write-Host ''
Write-Host 'wellutils installed!'
Write-Host "  scripts: $Bin"
Write-Host ''
Write-Host 'Usage: open a NEW terminal and run:  well mem  |  well fetch  |  well hw'
Write-Host 'Aliases are available too:  wellmem, wellusb, wellsensors, wfetch, ...'
