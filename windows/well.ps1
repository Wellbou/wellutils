# well.ps1 — wellutils for Windows (single-file port)
# One file, zero dependencies: Windows PowerShell 5.1+, data via CIM/WMI.
# Dispatch:  well.ps1 <tool> [options]     (shims wellusb.cmd … call this)
#           well.ps1 --lang RU|EN          persist language
#           well.ps1 --help                launcher help
# Mirrors the bash suite: same options, exit codes 0/2/3.

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$script:WU_VERSION = '1.4.0-47'

# tool key → display name / version / tagline
$script:TOOLS = @{
    usb     = @{ name = 'WellUSB';     ver = '2.0';   line = 'USB device listing (CIM)' }
    pci     = @{ name = 'WellPCI';     ver = '2.0';   line = 'PCI device listing (CIM)' }
    block   = @{ name = 'WellBlock';   ver = '1.0';   line = 'Block device listing' }
    mod     = @{ name = 'WellMod';     ver = '1.0';   line = 'Kernel drivers listing' }
    sensors = @{ name = 'WellSensors'; ver = '1.2';   line = 'Temperature monitor' }
    hw      = @{ name = 'WellHW';      ver = '1.3';   line = 'Hardware report' }
    mem     = @{ name = 'WellMem';     ver = '1.1';   line = 'Memory overview' }
    per     = @{ name = 'WellPer';     ver = '1.0';   line = 'Peripheral report' }
    fetch   = @{ name = 'wellfetch';   ver = '1.2.0'; line = 'System fetch' }
}

# aliases → canonical tool key
$script:ALIASES = @{
    'usb' = 'usb'; 'wellusb' = 'usb'; 'wusb' = 'usb'
    'pci' = 'pci'; 'wellpci' = 'pci'; 'wpci' = 'pci'
    'block' = 'block'; 'wellblock' = 'block'; 'wblock' = 'block'
    'mod' = 'mod'; 'wellmod' = 'mod'; 'wmod' = 'mod'
    'sensors' = 'sensors'; 'wellsensors' = 'sensors'; 'wsensors' = 'sensors'; 'wtemp' = 'sensors'
    'hw' = 'hw'; 'wellhw' = 'hw'; 'whw' = 'hw'
    'mem' = 'mem'; 'wellmem' = 'mem'; 'wmem' = 'mem'
    'ram' = 'mem'; 'wellram' = 'mem'; 'wram' = 'mem'
    'per' = 'per'; 'wellper' = 'per'; 'wper' = 'per'
    'fetch' = 'fetch'; 'wellfetch' = 'fetch'; 'wfetch' = 'fetch'
}

# ─── Language ───────────────────────────────────────────────────────
function Get-WuConfigDir {
    if ($env:WELLUTILS_CONFIG) { return $env:WELLUTILS_CONFIG }
    return (Join-Path $HOME '.config\wellutils')
}
function Get-WuLangFile { return (Join-Path (Get-WuConfigDir) 'lang.conf') }

function Get-WuLang {
    if ($env:WELLUTILS_LANG) { return $env:WELLUTILS_LANG.ToUpperInvariant() }
    $f = Get-WuLangFile
    if (Test-Path $f) {
        $c = ((Get-Content $f -Raw -ErrorAction SilentlyContinue) -split "`n")[0].Trim().ToUpperInvariant()
        if ($c -eq 'RU' -or $c -eq 'EN') { return $c }
    }
    if ([System.Globalization.CultureInfo]::CurrentUICulture.Name -match '^ru') { return 'RU' }
    return 'EN'
}
function Set-WuLangConf {
    param([string]$L)
    $d = Get-WuConfigDir
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
    Set-Content -Path (Get-WuLangFile) -Value $L -Encoding Ascii
}
function Get-WuHost {
    if ($env:COMPUTERNAME) { return $env:COMPUTERNAME }
    if ($env:HOSTNAME) { return $env:HOSTNAME }
    try { return (hostname).Trim() } catch { return '' }
}
function Get-WuUser {
    if ($env:USERNAME) { return $env:USERNAME }
    if ($env:USER) { return $env:USER }
    return $env:LOGNAME
}
$script:WU_LANG = Get-WuLang

# ─── Translations (mirror of bash _t_) ─────────────────────────────
$script:T_EN = @{
    no_data = 'No data available'; not_supported = 'not supported'
    total = 'Total'; used = 'Used'; free = 'Free'; available = 'Available'; reserved = 'Reserved'
    modules = 'Modules'; slot = 'Slot'; speed = 'Speed'
    cpu = 'CPU'; gpu = 'GPU'; board = 'Mainboard'; bios = 'BIOS'; ram = 'RAM'
    cores = 'Cores'; threads = 'Threads'; freq = 'Frequency'; cache = 'Cache'
    vram = 'VRAM'; driver = 'Driver'; model = 'Model'; vendor = 'Vendor'
    host = 'Host'; machine = 'Machine'; user = 'User'; uptime = 'Uptime'; version = 'Version'; shell = 'Shell'
    state = 'State'; path = 'Path'; disk = 'Disk'; partition = 'Partition'
    fs = 'Filesystem'; mount = 'Mount'; size = 'Size'; serial = 'Serial'
    usb = 'USB Devices'; pci = 'PCI Devices'; drivers = 'Kernel Drivers'
    sensors = 'Temperature Sensors'; temp = 'Temperature'; fans = 'Fans'
    devices = 'Devices'; no_devices = 'no devices detected'
    unknown = 'Unknown'; n_a = 'N/A'
}
$script:T_RU = @{
    no_data = 'Нет данных'; not_supported = 'не поддерживается'
    total = 'Всего'; used = 'Занято'; free = 'Свободно'; available = 'Доступно'; reserved = 'Зарезервировано'
    modules = 'Модули'; slot = 'Слот'; speed = 'Скорость'
    cpu = 'ЦП'; gpu = 'ГП'; board = 'Плата'; bios = 'BIOS'; ram = 'ОЗУ'
    cores = 'Ядер'; threads = 'Потоков'; freq = 'Частота'; cache = 'Кэш'
    vram = 'Видеопамять'; driver = 'Драйвер'; model = 'Модель'; vendor = 'Производитель'
    host = 'Хост'; machine = 'Машина'; user = 'Пользователь'; uptime = 'Аптайм'; version = 'Версия'; shell = 'Шелл'
    state = 'Состояние'; path = 'Путь'; disk = 'Диск'; partition = 'Раздел'
    fs = 'ФС'; mount = 'Метка'; size = 'Размер'; serial = 'Серийный'
    usb = 'USB'; pci = 'PCI'; drivers = 'Драйверы ядра'
    sensors = 'Датчики'; temp = 'Температура'; fans = 'Вентиляторы'
    devices = 'Устройства'; no_devices = 'устройств не найдено'
    unknown = 'Неизвестно'; n_a = 'Н/Д'
}
function T { param([string]$K)
    $d = if ($script:WU_LANG -eq 'RU') { $script:T_RU } else { $script:T_EN }
    if ($d.ContainsKey($K)) { return $d[$K] }
    return $K
}

# ─── Colors / VT ────────────────────────────────────────────────────
$script:WU_COLOR = 'auto'; $script:WU_PLAIN = $false; $script:WU_DEBUG = $false
$script:WU_EMOJI = 'auto'; $script:WU_TTY = $true
try { $script:WU_TTY = -not [Console]::IsOutputRedirected } catch { $script:WU_TTY = $true }

function Enable-WuVt {
    if ($Host.UI.SupportsVirtualTerminal) { return $true }
    if ($env:WT_SESSION) { return $true }
    try {
        $isWin = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
        if (-not $isWin) { return $false }
        $sig = '[DllImport("kernel32.dll",SetLastError=true)] public static extern IntPtr GetStdHandle(int n);'
        $sig += '[DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);'
        Add-Type -MemberDefinition $sig -Name WuVt -Namespace Wu -ErrorAction SilentlyContinue
        $h = [Wu.WuVt]::GetStdHandle(-11)
        [Wu.WuVt]::SetConsoleMode($h, 0x0004) | Out-Null
        return $true
    } catch { return $false }
}
$script:HAS_VT = Enable-WuVt

$script:C = @{}
function Init-WuColors {
    $script:C = @{}
    $on = ($script:WU_COLOR -eq 'always') -or
          ($script:WU_COLOR -eq 'auto' -and $script:WU_TTY -and $script:HAS_VT -and -not $env:NO_COLOR)
    if ($on) {
        $e = [char]27
        $script:C = @{ R = "$e[1;31m"; G = "$e[1;32m"; Y = "$e[1;33m"; B = "$e[1;34m"; M = "$e[1;35m"; Cc = "$e[1;36m"; W = "$e[1;37m"; DIM = "$e[2m"; BOLD = "$e[1m"; RESET = "$e[0m" }
    }
}
function Emoji-On {
    if ($script:WU_EMOJI -eq 'no') { return $false }
    if ($script:WU_EMOJI -eq 'yes') { return $true }
    return $script:HAS_VT
}
function Apply-WuStyle {
    # consume $st (parsed flags) into render globals; box/plain override,
    # otherwise auto-detect plaintext from TTY (no boxes/emoji in pipes).
    param($st)
    $script:WU_COLOR = $st.color
    $script:WU_EMOJI = $st.emoji
    if ($st.box) {
        $script:WU_PLAIN = $false
    } elseif ($st.plain) {
        $script:WU_PLAIN = $true
    } else {
        $script:WU_PLAIN = -not $script:WU_TTY
    }
}

# ─── CLI parsing (mirror of cli.sh) ────────────────────────────────
function Parse-WuArgs {
    # returns hashtable: help, version, lang, color, plain, box, emoji, debug, rest[]
    # -Raw: argument list to parse; -Extra: tool-specific flags allowed in rest
    param([string[]]$Raw = @(), [string[]]$Extra = @())
    $st = @{ help = $false; version = $false; lang = ''; color = 'auto'; plain = $false; box = $false; emoji = 'auto'; debug = $false; rest = @() }
    $a = @($Raw)
    for ($i = 0; $i -lt $a.Count; $i++) {
        $x = $a[$i]
        if ($x -eq '-h' -or $x -eq '--help') { $st.help = $true; continue }
        if ($x -eq '-V' -or $x -eq '--version') { $st.version = $true; continue }
        if ($x -eq '--lang') {
            $i++; if ($i -ge $a.Count) { Wu-Fail '--lang needs ru|en|auto'; return $null }
            $st.lang = $a[$i].ToLowerInvariant(); continue
        }
        if ($x -like '--lang=*') { $st.lang = $x.Substring(7).ToLowerInvariant(); continue }
        if ($x -eq '--color') {
            $i++; if ($i -ge $a.Count) { Wu-Fail '--color needs always|auto|never'; return $null }
            $st.color = $a[$i].ToLowerInvariant(); continue
        }
        if ($x -like '--color=*') { $st.color = $x.Substring(8).ToLowerInvariant(); continue }
        if ($x -eq '--plain') { $st.plain = $true; continue }
        if ($x -eq '--box') { $st.box = $true; continue }
        if ($x -eq '--no-emoji') { $st.emoji = 'no'; continue }
        if ($x -eq '--emoji') { $st.emoji = 'auto'; continue }
        if ($x -eq '--debug') { $st.debug = $true; continue }
        if ($x -like '-*') {
            if ($Extra -contains $x) { $st.rest += $x; continue }
            Wu-Fail ("unknown option {0}" -f $x)
            return $null
        }
        $st.rest += $x
    }
    if ($st.lang -ne '' -and $st.lang -notin @('ru', 'en', 'auto')) { Wu-Fail '--lang must be ru|en|auto'; return $null }
    if ($st.color -notin @('always', 'auto', 'never')) { Wu-Fail '--color must be always|auto|never'; return $null }
    if ($st.lang -eq 'ru') { $script:WU_LANG = 'RU' }
    elseif ($st.lang -eq 'en') { $script:WU_LANG = 'EN' }
    if ($st.debug) { $script:WU_DEBUG = $true; Set-PSDebug -Trace 1 }
    return $st
}
function Wu-Fail { param([string]$Msg)
    [Console]::Error.WriteLine($Msg)
    exit 2
}

# ─── Rendering ──────────────────────────────────────────────────────
function Write-Wu { param([string]$S)
    if ($S -ne '') { Write-Output $S }
}
function Write-WuHead { param([string]$Title, [string]$Icon = '')
    $c = $script:C
    if ($script:WU_PLAIN) {
        Write-Wu (("== {0} ==") -f $Title)
        return
    }
    $t = $Title
    if ($Icon -ne '' -and (Emoji-On)) { $t = "$Icon $t" }
    $bar = '═' * ($t.Length + 4)
    Write-Wu ("{0}╔{1}╗{2}" -f $c.Cc, $bar, $c.RESET)
    Write-Wu ("{0}║{1}  {2}  ║{3}" -f $c.Cc, $c.Cc, (("{0}{1}{2}" -f $c.BOLD, $t, $c.RESET)), $c.Cc)
    Write-Wu ("{0}╚{1}╝{2}" -f $c.Cc, $bar, $c.RESET)
}
function Write-WuRow { param([string]$Label, [string]$Value, [int]$Pad = 16)
    $c = $script:C
    if ($script:WU_PLAIN) {
        Write-Wu ("{0}: {1}" -f $Label, $Value)
        return
    }
    Write-Wu ("{0}{1}{2}  {3}{4}{5}" -f $c.B, $Label.PadRight($Pad), $c.RESET, $c.G, $Value, $c.RESET)
}
function Write-WuSep { param([string]$Title = '')
    $c = $script:C
    if ($script:WU_PLAIN) {
        # Keep the section header in plain mode too -- otherwise wellblock
        # drops the disk model and wellhw loses the board/BIOS Vendor labels
        # (same behaviour as the bash port, whose --plain keeps titles).
        if ($Title -eq '') { Write-Wu ''; return }
        Write-Wu $Title
        return
    }
    if ($Title -eq '') { Write-Wu ("{0}────────────────────{1}" -f $c.DIM, $c.RESET); return }
    Write-Wu ("{0}── {1} ──{2}" -f $c.DIM, $Title, $c.RESET)
}
function Write-WuBar { param([int]$Pct, [int]$Width = 24)
    $c = $script:C
    $fill = [Math]::Floor($Pct * $Width / 100)
    $bar = ('█' * $fill) + ('░' * ($Width - $fill))
    if ($script:WU_PLAIN) { return ("[{0}%]" -f $Pct) }
    $col = if ($Pct -lt 50) { $c.G } elseif ($Pct -lt 75) { $c.Y } elseif ($Pct -lt 90) { $c.M } else { $c.R }
    return ("{0}{1}{2}{3}%{4}" -f $col, $bar, $c.RESET, $Pct, $c.RESET)
}
function Format-Bytes { param([double]$Bytes)
    if ($Bytes -le 0) { return '0 B' }
    $steps = @('B', 'KB', 'MB', 'GB', 'TB', 'PB')
    $i = 0; $v = [double]$Bytes
    while ($v -ge 1024 -and $i -lt $steps.Length - 1) { $v /= 1024.0; $i++ }
    return ((NC '{0:N1} {1}' @($v, $steps[$i])))
}
function Format-Kb { param([double]$KB)
    return Format-Bytes ($KB * 1024.0)
}
function Format-Hz { param([double]$Hz)
    if ($Hz -ge 1e9) { return (NC '{0:N2} GHz' ($Hz / 1e9)) }
    if ($Hz -ge 1e6) { return (NC '{0:N0} MHz' ($Hz / 1e6)) }
    return (NC '{0:N0} kHz' ($Hz / 1e3))
}
function NC { param([string]$Fmt, [object[]]$Val)
    # invariant-culture formatting (dot decimal separators)
    return ([string]::Format([System.Globalization.CultureInfo]::InvariantCulture, $Fmt, $Val))
}
function Clean-Str { param($V)
    if ($null -eq $V) { return '' }
    return ([string]$V).Trim()
}
function Fmt-Val { param($V, [string]$Fallback = '')
    $s = Clean-Str $V
    if ($s -eq '') { return $Fallback }
    return $s
}

# ─── CIM abstraction ────────────────────────────────────────────────
# On real Windows uses Get-CimInstance. Testers may shadow it with a
# function of the same name to feed mock data (functions win over cmdlets).
function Get-WuCim {
    param([string]$Class, [string]$Namespace = 'root/cimv2')
    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        try { return @(Get-CimInstance -ClassName $Class -Namespace $Namespace -ErrorAction Stop) }
        catch { return @() }
    }
    return @()
}

# ─── Shared help/version ───────────────────────────────────────────
function Show-ToolUsage { param([string]$Tool)
    $m = $script:TOOLS[$Tool]
    Write-Wu ("Usage: well {0} [options]" -f $Tool)
    Write-Wu ''
    Write-Wu $m.line
    Write-Wu ''
    Write-Wu 'Options:'
    Write-Wu '  -h, --help              show this help'
    Write-Wu '  -V, --version           show version'
    Write-Wu '      --lang ru|en|auto   output language (auto = from locale)'
    Write-Wu '      --color always|auto|never   colorize output'
    Write-Wu '      --plain             plain text, no box drawing'
    Write-Wu '      --box               force box drawing'
    Write-Wu '      --no-emoji          drop emoji icons'
    Write-Wu '      --debug             trace'
    Write-Wu ''
    Write-Wu 'Exit codes: 0 ok, 2 bad CLI, 3 runtime error.'
}
function Show-ToolVersion { param([string]$Tool)
    $m = $script:TOOLS[$Tool]
    Write-Wu ("{0} {1}" -f $m.name, $m.ver)
    exit 0
}

# ─── wellmem ───────────────────────────────────────────────────────
function Show-WuMem {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) { Show-ToolUsage 'mem'; exit 0 }
    if ($st.version) { Show-ToolVersion 'mem' }
    $os = Get-WuCim 'Win32_OperatingSystem'
    if ($os.Count -eq 0) { Write-Wu (T no_data); exit 3 }
    $total = [double]$os[0].TotalVisibleMemorySize
    $free  = [double]$os[0].FreePhysicalMemory
    $used  = $total - $free
    $pct   = if ($total -gt 0) { [int](100 * $used / $total) } else { 0 }
    Write-WuHead 'Memory Overview' '🧠'
    Write-WuSep (T modules)
    $mods = Get-WuCim 'Win32_PhysicalMemory'
    $modTotal = 0.0
    foreach ($m in $mods) {
        $modTotal += [double]$m.Capacity
        Write-WuRow (Fmt-Val $m.DeviceLocator ('{0} {1}' -f (T slot), 0)) ((Format-Bytes ([double]$m.Capacity)) + '  ' + (Fmt-Val $m.Speed '') + ' MHz  ' + (Fmt-Val $m.Manufacturer (T unknown)))
    }
    Write-WuSep ''
    Write-WuRow (T total)  (Format-Kb $total)
    Write-WuRow (T used)   ((Format-Kb $used) + '   ' + (Write-WuBar $pct))
    Write-WuRow (T free)   (Format-Kb $free)
    Write-WuRow (T available) (Format-Kb $free)
    Write-WuRow 'Pagefile' (Format-Kb ([double]$os[0].TotalVirtualMemorySize - [double]$os[0].FreeVirtualMemory))
    Write-Wu ''
}

# ─── wellhw ───────────────────────────────────────────────────────
function Show-WuHw {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) { Show-ToolUsage 'hw'; exit 0 }
    if ($st.version) { Show-ToolVersion 'hw' }
    Write-WuHead 'Hardware Report' '🖥'
    $cpu = Get-WuCim 'Win32_Processor'
    if ($cpu.Count -gt 0) {
        $p = $cpu[0]
        Write-WuSep (T cpu)
        Write-WuRow (T model)  (Fmt-Val $p.Name (T unknown))
        Write-WuRow (T cores)  ([string]$p.NumberOfCores)
        Write-WuRow (T threads) ([string]$p.NumberOfLogicalProcessors)
        Write-WuRow (T freq)   (Format-Hz ([double]$p.MaxClockSpeed * 1e6))
        Write-WuRow (T cache)  ((Format-Bytes ([double]$p.L2CacheSize * 1024.0)) + ' L2 / ' + (Format-Bytes ([double]$p.L3CacheSize * 1024.0)) + ' L3')
    }
    $gpu = Get-WuCim 'Win32_VideoController'
    if ($gpu.Count -gt 0) {
        Write-WuSep (T gpu)
        foreach ($g in $gpu) {
            Write-WuRow (Fmt-Val $g.Name (T unknown)) ((Format-Bytes ([double]$g.AdapterRAM)) + '  ' + (Fmt-Val $g.DriverVersion ''))
        }
    }
    $board = Get-WuCim 'Win32_BaseBoard'
    if ($board.Count -gt 0) {
        Write-WuSep (T board)
        Write-WuRow (T vendor) (Fmt-Val $board[0].Manufacturer (T unknown))
        Write-WuRow (T model)  (Fmt-Val $board[0].Product (T unknown))
    }
    $bios = Get-WuCim 'Win32_BIOS'
    if ($bios.Count -gt 0) {
        Write-WuSep (T bios)
        Write-WuRow (T vendor) (Fmt-Val $bios[0].Manufacturer (T unknown))
        Write-WuRow (T version) (Fmt-Val $bios[0].SMBIOSBIOSVersion (T unknown))
    }
    $mods = Get-WuCim 'Win32_PhysicalMemory'
    if ($mods.Count -gt 0) {
        Write-WuSep (T ram)
        $t = 0.0
        foreach ($m in $mods) { $t += [double]$m.Capacity }
        Write-WuRow (T total) (Format-Bytes $t)
        Write-WuRow (T modules) ([string]$mods.Count)
    }
    Write-Wu ''
}

# ─── wellusb ───────────────────────────────────────────────────────
function Show-WuUsb {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) { Show-ToolUsage 'usb'; exit 0 }
    if ($st.version) { Show-ToolVersion 'usb' }
    $all = Get-WuCim 'Win32_PnPEntity'
    $devs = @($all | Where-Object { $_.DeviceID -like 'USB\*' })
    Write-WuHead 'USB Device Explorer' '🔌'
    if ($devs.Count -eq 0) { Write-Wu (T no_devices); Write-Wu ''; exit 0 }
    foreach ($d in $devs) {
        $name = Fmt-Val $d.Name (T unknown)
        $mfg  = Fmt-Val $d.Manufacturer ''
        Write-WuRow $name $mfg
    }
    Write-WuRow (T devices) ([string]$devs.Count)
    Write-Wu ''
}

# ─── wellpci ───────────────────────────────────────────────────────
function Show-WuPci {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) { Show-ToolUsage 'pci'; exit 0 }
    if ($st.version) { Show-ToolVersion 'pci' }
    $all = Get-WuCim 'Win32_PnPEntity'
    $devs = @($all | Where-Object { $_.DeviceID -like 'PCI\*' })
    Write-WuHead 'PCI Device Explorer' '🔧'
    if ($devs.Count -eq 0) { Write-Wu (T no_devices); Write-Wu ''; exit 0 }
    foreach ($d in $devs) {
        Write-WuRow (Fmt-Val $d.Name (T unknown)) (Fmt-Val $d.PNPClass '')
    }
    Write-WuRow (T devices) ([string]$devs.Count)
    Write-Wu ''
}

# ─── wellblock ─────────────────────────────────────────────────────
function Show-WuBlock {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) { Show-ToolUsage 'block'; exit 0 }
    if ($st.version) { Show-ToolVersion 'block' }
    Write-WuHead 'Block Device Explorer' '💾'
    $disks = Get-WuCim 'Win32_DiskDrive'
    foreach ($d in $disks) {
        Write-WuSep (Fmt-Val $d.Model (T unknown))
        Write-WuRow (T size)   (Format-Bytes ([double]$d.Size))
        Write-WuRow (T vendor) (Fmt-Val $d.Manufacturer '')
        Write-WuRow (T serial) (Fmt-Val $d.SerialNumber '')
        Write-WuRow (T partition) ([string]$d.Partitions)
    }
    if ($disks.Count -eq 0) { Write-Wu (T no_devices) }
    Write-WuSep (T fs)
    $vols = Get-WuCim 'Win32_LogicalDisk'
    foreach ($v in $vols) {
        $total = [double]$v.Size
        $freeV = [double]$v.FreeSpace
        $pct = if ($total -gt 0) { [int](100 * ($total - $freeV) / $total) } else { 0 }
        Write-WuRow (Fmt-Val $v.DeviceID '') (((Format-Bytes $freeV) + ' / ' + (Format-Bytes $total)) + '   ' + (Write-WuBar $pct) + '  ' + (Fmt-Val $v.FileSystem ''))
    }
    Write-Wu ''
}

# ─── wellmod ───────────────────────────────────────────────────────
function Show-WuMod {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) { Show-ToolUsage 'mod'; exit 0 }
    if ($st.version) { Show-ToolVersion 'mod' }
    Write-WuHead 'Kernel Drivers' '📦'
    $drv = Get-WuCim 'Win32_SystemDriver'
    if ($drv.Count -eq 0) { Write-Wu (T no_devices); Write-Wu ''; exit 0 }
    foreach ($d in $drv) {
        Write-WuRow (Fmt-Val $d.Name (T unknown)) ((Fmt-Val $d.State '') + '  ' + (Fmt-Val $d.PathName ''))
    }
    Write-WuRow (T devices) ([string]$drv.Count)
    Write-Wu ''
}

# ─── wellsensors ───────────────────────────────────────────────────
function Show-WuSensors {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) { Show-ToolUsage 'sensors'; exit 0 }
    if ($st.version) { Show-ToolVersion 'sensors' }
    Write-WuHead 'Temperature Sensors' '🌡'
    $zones = @()
    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        try { $zones = @(Get-CimInstance -Namespace root/wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop) }
        catch { $zones = @() }
    }
    if ($zones.Count -eq 0) {
        Write-Wu ((T temp) + ': ' + (T not_supported))
        Write-Wu ''
        exit 0
    }
    foreach ($z in $zones) {
        $c = ([double]$z.CurrentTemperature / 10.0) - 273.15
        Write-WuRow (Fmt-Val $z.InstanceName (T unknown)) ((NC '{0:N1}' $c) + ' °C')
    }
    Write-Wu ''
}

# ─── wellper ───────────────────────────────────────────────────────
function Show-WuPer {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) { Show-ToolUsage 'per'; exit 0 }
    if ($st.version) { Show-ToolVersion 'per' }
    Write-WuHead 'Peripherals Report' '🎮'
    $all = Get-WuCim 'Win32_PnPEntity'
    $usb = @($all | Where-Object { $_.DeviceID -like 'USB\*' })
    Write-WuSep (T usb)
    foreach ($d in $usb) { Write-WuRow (Fmt-Val $d.Name (T unknown)) (Fmt-Val $d.Manufacturer '') }
    if ($usb.Count -eq 0) { Write-Wu (T no_devices) }
    $mon = @($all | Where-Object { $_.PNPClass -eq 'Monitor' })
    Write-WuSep 'Displays'
    foreach ($d in $mon) { Write-WuRow (Fmt-Val $d.Name (T unknown)) (Fmt-Val $d.Status '') }
    if ($mon.Count -eq 0) { Write-Wu (T no_devices) }
    $aud = Get-WuCim 'Win32_SoundDevice'
    Write-WuSep 'Audio'
    foreach ($d in $aud) { Write-WuRow (Fmt-Val $d.Name (T unknown)) (Fmt-Val $d.Status '') }
    if ($aud.Count -eq 0) { Write-Wu (T no_devices) }
    Write-Wu ''
}

# ─── wellfetch ─────────────────────────────────────────────────────
$script:WF_LOGO = $true
$script:WF_FULL = $false
function Write-WuLogo {
    $c = $script:C
    $logo = @(
        '     W               W  ',
        '      W             W   ',
        '       W     W     W    ',
        '        W   W W   W     ',
        '         W W   W W      ',
        '          W     W       '
    )
    if ($script:WU_PLAIN) {
        foreach ($l in $logo) { Write-Wu $l.TrimEnd() }
        return
    }
    foreach ($l in $logo) { Write-Wu ("{0}{1}{2}" -f $c.M, $l, $c.RESET) }
}
function Get-VisLen { param([string]$S)
    ($S -replace "\x1b\[[0-9;]*m", '').Length
}
function Format-WuPair { param($p, [int]$Pad, [bool]$Plain)
    if ($Plain) { return ("{0}: {1}" -f $p.k, $p.v) }
    $c = $script:C
    return ("{0}{1}{2}  {3}{4}{5}" -f $c.B, $p.k.PadRight($Pad + 2), $c.RESET, $c.W, $p.v, $c.RESET)
}
function Show-WuFetch {
    param([string[]]$RawArgs)
    $st = Parse-WuArgs -Raw $RawArgs -Extra @('--no-logo', '--full')
    if (-not $st) { exit 2 }
    Apply-WuStyle $st
    Init-WuColors
    if ($st.help) {
        Show-ToolUsage 'fetch'
        Write-Wu '      --no-logo           text only, no logo'
        Write-Wu '      --full              one section per line'
        exit 0
    }
    if ($st.version) { Show-ToolVersion 'fetch' }
    foreach ($r in $st.rest) {
        if ($r -eq '--no-logo') { $script:WF_LOGO = $false }
        elseif ($r -eq '--full') { $script:WF_FULL = $true }
        elseif ($r -like '-*') { Wu-Fail ("unknown option {0}" -f $r) }
    }
    $os = Get-WuCim 'Win32_OperatingSystem'
    $cpu = Get-WuCim 'Win32_Processor'
    $gpu = Get-WuCim 'Win32_VideoController'
    $pairs = [System.Collections.Generic.List[object]]::new()
    if ($os.Count -gt 0) {
        $boot = $null
        try { $boot = $os[0].LastBootUpTime } catch {}
        if ($null -ne $boot) {
            $up = (Get-Date) - $boot
            $pairs.Add(@{ k = (T uptime); v = ("{0}d {1}h {2}m" -f $up.Days, $up.Hours, $up.Minutes) })
        }
        $pairs.Add(@{ k = (T version); v = (Fmt-Val ($os[0].Caption) (T unknown)) })
        $pairs.Add(@{ k = 'Build'; v = (Fmt-Val $os[0].BuildNumber '') })
    }
    $pairs.Add(@{ k = (T host); v = (Get-WuHost) })
    $pairs.Add(@{ k = (T user); v = (Get-WuUser) })
    if ($cpu.Count -gt 0) { $pairs.Add(@{ k = (T cpu); v = (Fmt-Val $cpu[0].Name (T unknown)) }) }
    if ($gpu.Count -gt 0) { $pairs.Add(@{ k = (T gpu); v = (Fmt-Val $gpu[0].Name (T unknown)) }) }
    if ($os.Count -gt 0) {
        $tot = [double]$os[0].TotalVisibleMemorySize
        $fre = [double]$os[0].FreePhysicalMemory
        $pairs.Add(@{ k = (T ram); v = ((Format-Kb $fre) + ' / ' + (Format-Kb $tot)) })
    }
    $pairs.Add(@{ k = (T shell); v = $PSVersionTable.PSVersion.ToString() })
    if ($script:WF_LOGO) { Write-WuLogo }
    $pad = 0
    foreach ($p in $pairs) { if ($p.k.Length -gt $pad) { $pad = $p.k.Length } }
    if ($script:WF_FULL -or $script:WU_PLAIN) {
        foreach ($p in $pairs) { Write-Wu (Format-WuPair $p $pad $script:WU_PLAIN) }
    } else {
        # default: pair short sections on one line (gap 6, cap 74 like bash)
        $pending = $null
        foreach ($p in $pairs) {
            if ($null -eq $pending) { $pending = $p; continue }
            $l1 = Format-WuPair $pending $pad $false
            $l2 = Format-WuPair $p $pad $false
            if ((Get-VisLen $l1) + 6 + (Get-VisLen $l2) -le 74) {
                Write-Wu ($l1 + (' ' * 6) + $l2)
                $pending = $null
            } else {
                Write-Wu $l1
                $pending = $p
            }
        }
        if ($null -ne $pending) { Write-Wu (Format-WuPair $pending $pad $false) }
    }
    Write-Wu ''
}

# ─── Launcher (wellutils) ─────────────────────────────────────────
function Show-LauncherHelp {
    $c = $script:C
    Write-Wu ''
    if ($script:WU_PLAIN) {
        Write-Wu 'wellutils — System Utility Kit (Windows)'
    } else {
        $title = 'wellutils — System Utility Kit (Windows)'
        $bar = '═' * ($title.Length + 4)
        Write-Wu ("{0}╔{1}╗{2}" -f $c.Cc, $bar, $c.RESET)
        Write-Wu ("{0}║{1}  {2} {3}║{4}" -f $c.Cc, $c.RESET, $c.BOLD, (($title) + ($c.RESET)), $c.Cc)
        Write-Wu ("{0}╚{1}╝{2}" -f $c.Cc, $bar, $c.RESET)
    }
    Write-Wu ''
    Write-Wu 'Usage:'
    Write-Wu '    well <command> [options]'
    Write-Wu '    well --lang RU|EN'
    Write-Wu '    well --help'
    Write-Wu ''
    Write-Wu 'Commands:'
    $names = @('usb', 'pci', 'block', 'mem', 'mod', 'sensors', 'hw', 'per', 'fetch')
    foreach ($n in $names) {
        $m = $script:TOOLS[$n]
        Write-Wu ("    {0,-10} — {1}" -f $n, $m.line)
    }
    Write-Wu ''
    Write-Wu 'Aliases: usb=wellusb=wusb  pci=wellpci=wpci  block=wellblock=wblock'
    Write-Wu '         mem=wellmem=wmem=ram=wellram=wram  mod=wellmod=wmod'
    Write-Wu '         sensors=wellsensors=wsensors=wtemp  hw=wellhw=whw'
    Write-Wu '         per=wellper=wper  fetch=wellfetch=wfetch'
    Write-Wu ''
    Write-Wu ("Current language: {0}" -f $script:WU_LANG)
    Write-Wu ''
}

# ─── Entry ─────────────────────────────────────────────────────────
# Run only when executed, not when dot-sourced (tests dot-source this file)
if ($MyInvocation.InvocationName -eq '.') {
    $script:WU_SOURCED = $true
} else {
    $script:WU_SOURCED = $false
    $argsArr = @($args)
    if ($argsArr.Count -eq 0) {
        $script:WU_PLAIN = (-not $script:WU_TTY)
        Init-WuColors
        Show-LauncherHelp
        exit 0
    }

    $cmd = $argsArr[0]
    if ($cmd -eq '--lang' -or $cmd -eq '-l') {
        if ($argsArr.Count -lt 2) { Wu-Fail '--lang needs RU|EN' }
        $l = $argsArr[1].ToUpperInvariant()
        if ($l -notin @('RU', 'EN')) { Wu-Fail '--lang must be RU|EN' }
        Set-WuLangConf $l
        Write-Wu ("Language set to: {0}" -f $l)
        exit 0
    }
    if ($cmd -eq '--help' -or $cmd -eq '-h') {
        $script:WU_PLAIN = (-not $script:WU_TTY)
        Init-WuColors
        Show-LauncherHelp
        exit 0
    }
    if ($cmd -eq '--version' -or $cmd -eq '-V') {
        Write-Wu ("wellutils {0}" -f $script:WU_VERSION)
        exit 0
    }

    $tool = $null
    if ($script:ALIASES.ContainsKey($cmd)) { $tool = $script:ALIASES[$cmd] }
    if (-not $tool) {
        [Console]::Error.WriteLine(("unknown command {0}" -f $cmd))
        exit 2
    }
    if ($argsArr.Count -gt 1) { $rest = @($argsArr[1..($argsArr.Count - 1)]) } else { $rest = @() }
    switch ($tool) {
        'mem'     { Show-WuMem -RawArgs $rest }
        'hw'      { Show-WuHw -RawArgs $rest }
        'usb'     { Show-WuUsb -RawArgs $rest }
        'pci'     { Show-WuPci -RawArgs $rest }
        'block'   { Show-WuBlock -RawArgs $rest }
        'mod'     { Show-WuMod -RawArgs $rest }
        'sensors' { Show-WuSensors -RawArgs $rest }
        'per'     { Show-WuPer -RawArgs $rest }
        'fetch'   { Show-WuFetch -RawArgs $rest }
        default   { exit 2 }
    }
    exit 0
}
