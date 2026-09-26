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

# Version compare like windows/install.sh ver_gt: split on . - _, numeric
# parts compared as numbers, others as strings. $true if $A > $B.
function Test-WuVerGt {
    param([string]$A, [string]$B)
    $x = @($A.TrimStart('v') -split '[.\-_]')
    $y = @($B.TrimStart('v') -split '[.\-_]')
    $n = [Math]::Max($x.Count, $y.Count)
    for ($i = 0; $i -lt $n; $i++) {
        $p = if ($i -lt $x.Count -and $x[$i] -ne '') { $x[$i] } else { '0' }
        $q = if ($i -lt $y.Count -and $y[$i] -ne '') { $y[$i] } else { '0' }
        if ($p -match '^\d+$' -and $q -match '^\d+$') {
            $pn = [decimal]$p; $qn = [decimal]$q
            if ($pn -gt $qn) { return $true }
            if ($pn -lt $qn) { return $false }
        } else {
            $c = [string]::CompareOrdinal($p, $q)
            if ($c -gt 0) { return $true }
            if ($c -lt 0) { return $false }
        }
    }
    return $false
}

# Newest tag, not /releases/latest: a stale GitHub Release can lag far
# behind the tags (same logic as install.sh and windows/install.sh).
$tag = $null
try {
    $tags = Invoke-RestMethod -Uri "$Api/tags?per_page=100" -Headers @{ 'User-Agent' = 'wellutils-installer' }
    foreach ($t in @($tags)) {
        $name = [string]$t.name
        if ($name -notmatch '^v\d') { continue }
        if (-not $tag -or (Test-WuVerGt $name $tag)) { $tag = $name }
    }
    if ($tag) { Write-Host "Found tag: $tag" }
} catch { $tag = $null }

$src = $null
if ($tag) {
    try { $src = Get-WuSource $tag } catch { $src = $null; Write-Host "Tag $tag not downloadable, falling back to main." }
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
