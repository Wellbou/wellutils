<p align="right">
  <a href="README.md">English</a> ·
  <b>Русский</b>
</p>

<div align="center">

  <img src="logo.png" alt="wellutils" width="128">

  # wellutils

  Набор утилит для отчётов о системе и периферии для Arch Linux
  плюс порт на PowerShell для Windows без единой зависимости.

  [![Язык: Bash](https://img.shields.io/badge/Language-Bash-4EAA25?logo=gnubash&logoColor=white)](wellutils)
  [![Язык: Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python&logoColor=white)](wfetch_art.py)
  [![Платформа: Arch Linux](https://img.shields.io/badge/Platform-Arch_Linux-1793D1?logo=archlinux&logoColor=white)](PKGBUILD)
  [![Платформа: Windows](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)](windows/well.ps1)
  [![Версия: 1.4.0](https://img.shields.io/badge/Version-1.4.0-22272E)](PKGBUILD)
  [![Лицензия: MIT](https://img.shields.io/badge/License-MIT-C16CFF)](LICENSE)

</div>

---

## Что это

Одиннадцать файлов-инструментов, которые рассказывают, что делает
ваша машина: USB и PCI-устройства, накопители, память, топология
процессора, графика, модули ядра, температуры и периферия. У каждого
инструмента один и тот же CLI — общие флаги, общие коды возврата,
общий вывод в рамке. Лаунчер (`wellutils`) связывает их вместе,
а короткие алиасы (`wusb`, `wpci`, `wmem`, ...) устанавливаются рядом.

Тот же интерфейс поставляется одним PowerShell-файлом для Windows.
Без WSL, без прав администратора, без установщиков — данные читаются
через CIM/WMI.

```
$ well fetch

  User: wellbou_@lor
  OS: Arch Linux (x86_64)
  Kernel: 7.1.6-arch1-1
  Uptime: 5h 14m · boot 2026-08-11 11:59
  CPU: Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
        4 cores / 8 threads @ 3500 MHz · load 5.79
  GPU: GP107 [GeForce GTX 1050 Ti] · 4 GiB
  Memory: 7 GiB / 7 GiB (93%)
  Resolution: 1600x900
```

## Содержание

- [Установка](#установка)
- [Использование](#использование)
- [Инструменты](#инструменты)
- [Возможности](#возможности)
- [Зависимости](#зависимости)
- [Лицензия](#лицензия)

## Установка

### Arch Linux

Из AUR после публикации либо сборкой из этого репозитория:

```sh
yay -S wellutils      # или любой другой AUR-хелпер

# из репозитория
makepkg -si
```

Устанавливаются бинарники, man-страницы, bash-комплеты и файлы
данных в `/usr/share/wellutils` (таблица JEDEC-кодов, помощники
box/CLI, логотип).

### Windows

Используется PowerShell из состава Windows — скачивается ровно один
файл, ничего больше. Выберите один вариант:

```powershell
# PowerShell 5.1 или 7
irm https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.ps1 | iex
```

```bash
# Git Bash / MSYS2
curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.sh | bash
```

Это разместит `well.ps1` и шимы `well*.cmd` в
`%USERPROFILE%\.wellutils\bin` и добавит каталог в пользовательский
PATH. Откройте новый терминал, затем:

```
well mem     | well fetch   | well hw
wellmem      | wellusb      | wellsensors   # отдельные шимы
wmem -l en   | well usb --plain
```

Ничего не выполняется от администратора; все данные читаются через
CIM/WMI.

## Использование

У каждого инструмента один и тот же CLI:

```
tool [options]

  -h, --help               показать справку
  -V, --version            показать версию
      --lang ru|en|auto    язык вывода (auto = локаль системы)
      --color always|auto|never
      --plain              обычный текст, без рамок
      --box                принудительно рамки
      --no-emoji           без иконок-эмодзи
      --json               машиночитаемый JSON в stdout
      --debug              трассировка shell
```

Каждый инструмент умеет выводить JSON — передавайте его в `jq` или
сохраняйте для сервисной интеграции. Предупреждения и ошибки идут в
stderr, так что поток JSON всегда чистый:

```sh
wellhw --json | jq '.cpu.model'
wellsensors --json | jq -c '.summary'
wellblock 0 --json | jq '.disk.partitions'
```

Запускайте инструмент напрямую или через лаунчер:

```sh
wellhw --plain
wellutils hw --plain
wmem -l en
wellper --groups --json
```

У `wellper` есть ещё `--groups`, `--sections`, `--strict`, `--terse`
(а `--json` теперь есть у всех инструментов). `wellblock` принимает
необязательный аргумент `[N|device]` для детального просмотра
отдельного диска с отчётом S.M.A.R.T.:

```sh
wblock 0          # первый диск
wblock sdb        # по имени устройства
wblock /dev/sdb
```

У каждого инструмента есть man-страница (`man wellper`) и bash-комплет.

## Инструменты

| Инструмент    | Что выводит                                                 |
|---------------|-------------------------------------------------------------|
| `wellper`     | Периферия: USB-устройства, экраны, аудио                     |
| `wellhw`      | Железо: CPU, GPU, плата, память с JEDEC-декодированием       |
| `wellmem`     | Память из `/proc/meminfo`, включая zram                     |
| `wellusb`     | Дерево USB-устройств с расшифровкой ID из hwdata             |
| `wellpci`     | PCI-устройства с описаниями классов                          |
| `wellblock`   | Накопители, разделы, точки монтирования, здоровье S.M.A.R.T. |
| `wellcpu`     | Топология CPU, частоты, возможности, нагрузка по ядрам       |
| `wellgpu`     | Графика: шина, вендор, драйвер, живая статистика NVIDIA     |
| `wellmod`     | Загруженные модули ядра                                      |
| `wellsensors` | Температуры и вентиляторы: hwmon, lm_sensors, nvidia-smi    |
| `wellfetch`   | Инфо о системе с ASCII- или PNG-логотипом                    |

Короткие алиасы устанавливаются как команды: `wusb`, `wpci`,
`wblock`, `wcpu`, `wgpu`, `wmem`/`wram`/`wellram`, `wmod`,
`wsensors`/`wtemp`, `whw`, `wper`, `wfetch`. Лаунчер принимает и их:
`wellutils wram --plain`.

Замечание: `wellutils sensors` намеренно не является алиасом — он
перекрыл бы бинарник `sensors` из lm_sensors. Используйте
`wellsensors` или `wtemp`.

## Возможности

- **Классификация USB по классам интерфейсов.** Композитные
  устройства классифицируются по классам интерфейсов (принтер `07`,
  хранилище `08`, веб-камера `0e`, сеть `02`, аудио `01/04`, данные
  `06`, хаб `09`), поэтому принтеры, веб-камеры и геймпады
  определяются верно, даже когда `bDeviceClass` сообщает `0x00` или
  `0xEF`.
- **JEDEC-декодирование вендоров памяти.** `wellhw` расшифровывает
  сырые коды JEP106 из dmidecode (например, `8313` → Golden Empire).
  Таблица ID поставляется как `/usr/share/wellutils/jedec.sh`.
- **Root не требуется.** Всё читается из sysfs и `/proc`. dmidecode
  и decode-dimms используются только при настроенном sudo без пароля.
- **Здоровье S.M.A.R.T. в `wellblock`.** Просмотр диска проверяет
  общее состояние и подсвечивает цветом вышедшие из нормы
  критические атрибуты (реаллоцированные сектора, pending и
  uncorrectable ошибки, CRC-ошибки).
- **Одинаковые опции везде.** Один CLI, один стиль вывода, один набор
  кодов возврата — и в Linux, и в Windows.

## Зависимости

**Обязательные:** `bash`, `python`, `coreutils`, `procps-ng`,
`hwdata`.

**Опциональные:** `pciutils` (описания PCI), `usbutils` (перечень
USB), `smartmontools` (wellsensors и S.M.A.R.T. в wellblock),
`nvme-cli` (температуры NVMe), `dmidecode` + `i2c-tools` (детали
памяти через decode-dimms), `util-linux` (lscpu для wellcpu).

## Лицензия

MIT, кроме таблицы вендоров JEDEC JEP106 (`jedec.sh`), извлечённой
из i2c-tools `decode-dimms` (GPL-2.0, (c) авторы i2c-tools).
Полная атрибуция — в `LICENSE`.
