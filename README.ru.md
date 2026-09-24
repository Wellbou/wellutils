<p align="right">
  <a href="README.md">English</a> ·
  <b>Русский</b>
</p>

<div align="center">

  <img src="logo.png" alt="wellutils" width="128">

  # wellutils

  Набор утилит для отчётов о системе и периферии для любого Linux
  (Arch, Fedora, Debian, Ubuntu, Bodhi, openSUSE, Alpine, ...)
  плюс порт на PowerShell для Windows без единой зависимости.

  [![Язык: Bash](https://img.shields.io/badge/Language-Bash-4EAA25?logo=gnubash&logoColor=white)](wellutils)
  [![Язык: Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python&logoColor=white)](src/wfetch_art.py)
  [![Платформа: Linux](https://img.shields.io/badge/Platform-Linux-1793D1?logo=linux&logoColor=white)](install.sh)
  [![Платформа: Windows](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)](windows/well.ps1)
  [![Версия: 1.4.0-54](https://img.shields.io/badge/Version-1.4.0--54-22272E)](PKGBUILD)
  [![Лицензия: MIT](https://img.shields.io/badge/License-MIT-C16CFF)](src/LICENSE)

</div>

---

## Что это

Шестнадцать файлов-инструментов, которые рассказывают, что делает
ваша машина: USB и PCI-устройства, накопители, память, топология
процессора, графика, модули ядра, температуры, периферия, сеть,
питание, агрегатор здоровья и офлайн HTML-отчёт. В Linux у всех
инструментов общий базовый CLI - общие флаги, общие коды возврата,
общий вывод в рамке. Лаунчер (`wellutils`) связывает их вместе, а
короткие алиасы (`wusb`, `wpci`, `wmem`, ...) устанавливаются рядом.

Урезанная версия того же интерфейса поставляется одним
PowerShell-файлом для Windows. Без WSL, без прав администратора, без
установщиков - данные читаются через CIM/WMI. Честно говоря, порт для
Windows довольно сырой: в нём нет `--json`, `--short` и `--html`, так
что там вывод можно в основном просто посмотреть:

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
- [Документация](#документация)
- [Скрипты и --json](#скрипты-и---json)
- [Возможности](#возможности)
- [Зависимости](#зависимости)
- [Лицензия](#лицензия)

## Установка

### Любой Linux (Arch, Fedora, Debian, Ubuntu, Bodhi, openSUSE, Alpine, ...)

Одна команда - установщик сам определяет ваш пакетный менеджер
(pacman, dnf/yum, apt, zypper, apk, xbps, emerge), ставит зависимости (база ID hwdata, lm-sensors,
smartmontools, dmidecode, ...) и кладёт инструменты в `/usr/local/bin`:

```sh
curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/install.sh | bash
```

Нет `curl`? `wget` тоже подойдёт:

```sh
wget -qO- https://raw.githubusercontent.com/Wellbou/wellutils/main/install.sh | bash
```

> **Голый Alpine:** в базовом образе нет `bash`, а `install.sh` без
> него не работает (ещё нужен `curl` или `wget`). Сначала:
> `apk add bash curl`.

Пропустить установку зависимостей можно флагом `--no-deps`
(инструменты корректно деградируют: без S.M.A.R.T., без показаний
датчиков, без имён вендоров по ID).

- **Без root:** `./install.sh --prefix=$HOME/.local` ставит всё в
  домашний каталог, sudo не нужен. Проверьте, что `~/.local/bin` есть
  в `PATH`.
- **Termux (Android):** работает без root; установщик использует
  `pkg` и ставит в собственный `$PREFIX` Termux. Часть данных
  (S.M.A.R.T., dmidecode, кусок sysfs) приложениям на Android просто
  не видна, так что эти секции останутся пустыми.
- **NixOS:** установщик только копирует файлы и по умолчанию ставит
  в `~/.local`; нужные зависимости (`smartmontools`, `pciutils`,
  `lm_sensors`, ...) добавьте через конфигурацию Nix.

### Из исходников (git clone)

Склонируйте репозиторий и запустите тот же установщик из клона:

```sh
git clone https://github.com/Wellbou/wellutils.git
cd wellutils
./install.sh
```

Все скрипты лежат в `src/`, так что инструменты можно запускать прямо
из клона без установки:

```sh
./src/wellcpu --short
./src/welldoctor --json
```

### Arch Linux (пакет)

Сборка из этого репозитория:

```sh
makepkg -si
```

Устанавливаются бинарники, man-страницы, bash-комплеты и файлы
данных в `/usr/share/wellutils` (таблица JEDEC-кодов, помощники
box/CLI, логотип).

### Windows

Используется PowerShell из состава Windows - скачивается ровно один
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

У всех Linux-инструментов общий базовый CLI (некоторые добавляют
свои флаги сверху - их показывает `--help` каждого инструмента):

```
tool [options]

  -h, --help               показать справку
  -V, --version            показать версию
      --lang ru|en|auto    язык вывода (auto = язык системы)
      --color always|auto|never
      --plain              обычный текст, без рамок
      --box                принудительно рамки
      --no-emoji           без эмодзи
      --emoji               принудительно включить эмодзи
      --json               машиночитаемый JSON в stdout
      --short              одна строка статуса (только "живые" тулы)
      --html               отдельная HTML-страница
      --debug              трассировка shell

Коды выхода: 0 ok, 2 ошибка CLI, 3 ошибка выполнения
(welldoctor: 0 здоров, 1 предупреждения, 2 критично, 3 ошибка выполнения)
```

Каждый инструмент умеет выводить JSON - передавайте его в `jq` или
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

У `wellper` есть ещё `--groups`, `--sections`, `--strict`, `--terse`. `wellblock` принимает
необязательный аргумент `[N|device]` для детального просмотра
отдельного диска с отчётом S.M.A.R.T.:

```sh
wblock 0          # первый диск
wblock sdb        # по имени устройства
wblock /dev/sdb
```

У каждого инструмента есть man-страница (`man wellper`) и комплеты
для bash, zsh и fish.

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
| `wellup`      | Проверка и автоматическое обновление системы                 |
| `wellnet`     | Офлайн-обзор сети: интерфейсы, Wi-Fi, маршруты, порты        |
| `wellpower`   | Износ батареи, циклы, пороги заряда, профили питания         |
| `welldoctor`  | Агрегатор здоровья для cron: SMART, температуры, юниты, диск |
| `whtml`       | Офлайн HTML-отчёт о системе: CLI-стиль.                      |

Короткие алиасы устанавливаются как команды: `wusb`, `wpci`,
`wblock`, `wcpu`, `wgpu`, `wmem`/`wram`/`wellram`, `wmod`,
`wsensors`/`wtemp`, `whw`, `wper`, `wfetch`, `wup`, `wnet`,
`wpower`/`wbatt`, `wdoc`/`wdoctor`. `whtml` доступен и как
`wellutils html` или `wellutils report`. Лаунчер принимает их все:
`wellutils wram --plain`.

`wellup` спрашивает подтверждение перед применением обновлений;
флаг `--yes` пропускает вопрос (для скриптов и cron). Умеет он и
обновлять сам wellutils с GitHub:

```sh
wellup --check                # только показать доступные обновления
wellup                        # показать и спросить перед применением
wellup --yes                  # применить без подтверждения
wellup --self-update          # проверить и обновить wellutils
wellup --self-update --check  # только показать разницу версий
```

## Документация

- [**docs/SCRIPTING.ru.md**](docs/SCRIPTING.ru.md) - туториал по `--json`. Разьясняется на `whtml`, также рассказывается по
  нагрузке по ядрам, температуре GPU, cron-сторожам, диффам инвентаря.
- [**SAMPLES.md**](SAMPLES.md) - реальный, неотредактированный вывод
  каждого тула с машины Wellbou (т.е. моей, собстсвн): можно заранее посмотреть, что и как
  печатает каждая команда.

## Режим для статус-баров

Каждый "живой" (не знаю, как еще назвать) тул с `--short` печатает одну строку - для i3blocks,
waybar, polybar и tmux:

```sh
wellcpu --short      # 17%
wellmem --short      # 1.9/3.8GiB
wellsensors --short  # 52°C
wellgpu --short      # 53°C 36%
wellpower --short    # 85%+ (износ 7%)
```

Пример для waybar: `custom-cpu = { exec: "wellcpu --short"; interval: 3; }`

## Скрипты и --json

Каждый отчётный тул умеет отдавать единый машинно-читаемый JSON
(`--json`) - а `whtml`, надеюсь, мотивирует этот формат изучить. Он сам не читает ни sysfs, ни `/proc` - просто запускает
остальные тулы с `--json`, склеивает их вывод и делает из него одну
HTML-страницу. Что бы вы ни хотели заскриптовать, думаю, с wellutils у вас получится.

```sh
# вот так работает whtml - поверхностно, очевидно, просто показываю команду
whtml --output ~/report.html
```

То же самое можно просто использовать и напрямую:

```sh
wellhw --json | jq -r '.cpu.model'      # CPU этой машины
wellcpu --json | jq -r '.load[].usage_percent'   # нагрузка по ядрам
```

Все тулы используют общий конверт `{ "tool", "version", "date", ... }`.
Полный туториал - сторожи, cron-проверки, диффы инвентаря - в
[`docs/SCRIPTING.ru.md`](docs/SCRIPTING.ru.md), а реальный вывод каждого
тула - в [SAMPLES.md](SAMPLES.md).

## Новое в 1.4.0-54

Этот выпуск в основном про то, чтобы wellutils работал не только на
моей машине. Я постарался пройтись по как можно большему числу
странных конфигураций; часть из них получилось проверить только
"на бумаге", так что если у вас что-то всё ещё ломается - напишите,
пожалуйста.

- Рамки и эмодзи: движок ширины переписан. Рамки теперь ровные во всех
  тулах (широкие и узкие эмодзи, кириллица, CJK), а ширина берётся
  из настоящего терминала, а не угадывается.
- Работает на большем числе систем: busybox, Alpine/musl, старый
  Debian с mawk, Termux на Android, ARM-платы, Маки на Asahi и
  машины POWER. Где нет SMBIOS, имена CPU и платы читаются из
  device tree.
- Мусор из SMBIOS вроде "To Be Filled By O.E.M." или "Not Specified"
  теперь отфильтровывается, а не печатается как настоящее имя.
- Исправлено JEDEC-декодирование: бит чётности обрабатывался неверно,
  из-за чего Samsung, SK Hynix, Kingston, Crucial и другие не
  расшифровывались. Теперь расшифровываются.
- `wellusb` теперь сканирует USB-устройства напрямую через sysfs.
- `welldoctor` больше не выдаёт ложный "S.M.A.R.T. ПРОВАЛЕН": раньше
  он цеплялся за заголовок столбца в таблице smartctl. Также systemd
  внутри контейнеров теперь считается недоступным, а не "всё хорошо",
  а `--short` возвращает те же коды 0/1/2, что и остальные режимы.
- Много исправлений падений: `wellnet` на ноутбуках с Wi-Fi, `wellmem`
  с ECC-памятью, `wellfetch --all` и не только.
- Исправления установщика: теперь ставится `parse.sh` (без него тулы
  не запускались), поддержка Termux и NixOS, правильные пути комплетов,
  `curl` или `wget`.
- `whtml`: все значения корректно экранируются (странное имя
  устройства больше не может сломать страницу), ошибки записи
  сообщаются с кодом выхода 3, и работает он заметно быстрее.
- Комплеты генерируются из `--help` каждого тула, так что наконец
  совпадают с настоящими флагами; у лаунчера тоже появились комплеты.
- Общее ускорение: намного меньше подпроцессов в циклах, что очень
  заметно на медленных нетбуках и одноплатниках.

## Новое в 1.4.0-47

- Лаунчер `wellutils` теперь показывает `whtml` как команду верхнего
  уровня (раньше она пряталась за алиасом `report`).
- Новый [**docs/SCRIPTING.ru.md**](docs/SCRIPTING.ru.md) - контракт
  `--json` на живом примере `whtml`.
- `whtml --ami` - режим AMI BIOS: палитра xb-16, шрифт Perfect DOS VGA,
  горячие клавиши F1/F9/F10/Esc. Оно немного не нужно, но зато у меня больше нет неудержимого желания сделать что-то подобное. Да и оно круто, правда ведь?
- `whtml` - полностью офлайн HTML-отчёт с CLI-стилем.
- `wellnet` - полностью офлайн-обзор сети: интерфейсы, адреса, Wi-Fi,
  маршруты, порты, счётчики трафика и определение типа подключения.
- `wellpower` - износ батареи, циклы, пороги заряда, профили питания.
- `welldoctor` - агрегатор здоровья для cron (SMART, температуры,
  сбойные юниты, место на диске, pacnew-хвосты, сироты); код выхода 0/1/2.
- `wellhw --snapshot [файл]` / `--diff [файл]` - "что изменилось с той недели". Где-нибудь оно точно пригодится. Надеюсь.
- `wellup --pacnew` - список остаточных конфигов.
- `--html` у всех отчётных тулов - готовая HTML-страница отчёта.
- ASCII-логотипы дистрибутивов в wellfetch (`--png` вернёт пиксельный).
- Комплеты zsh и fish рядом с bash.

`wellutils sensors` работает как алиас для `wellsensors`. Другие
алиасы: `wsensors`, `wtemp`. Полный список см. в wellutils(1).

## Возможности

- **Классификация USB по классам интерфейсов.** Композитные
  устройства классифицируются по классам интерфейсов (принтер `07`,
  хранилище `08`, веб-камера `0e`, сеть `02`, аудио `01/04`, данные
  `06`, хаб `09`), поэтому принтеры, веб-камеры и геймпады
  определяются верно, даже когда `bDeviceClass` сообщает `0x00` или
  `0xEF`.
- **JEDEC-декодирование вендоров памяти.** `wellhw` расшифровывает
  сырые коды JEP106 из dmidecode (например, `8313` -> Golden Empire).
  Таблица ID поставляется как `/usr/share/wellutils/jedec.sh`.
- **Root не требуется.** Всё читается из sysfs и `/proc`. dmidecode
  и decode-dimms используются только при настроенном sudo без пароля.
- **Здоровье S.M.A.R.T. в `wellblock`.** Просмотр диска проверяет
  общее состояние и подсвечивает цветом вышедшие из нормы
  критические атрибуты (реаллоцированные сектора, pending и
  uncorrectable ошибки, CRC-ошибки).
- **Одинаковые базовые опции у всех Linux-тулов.** Один CLI, один
  стиль вывода, один набор кодов возврата. Порт для Windows выглядит
  так же и понимает базовые флаги, но в нём нет `--json`, `--short` и
  `--html`.

## Зависимости

**Обязательные:** `bash` 4.0 или новее, `coreutils` (busybox тоже
подойдёт), `procps-ng` (`procps` на Debian/Ubuntu). Для установщика:
`curl` или `wget`.

**Python не обязателен:** `python3` нужен только `whtml` и
PNG-логотипу `wellfetch` (`--png`). Всё остальное - чистый bash.

**Опциональные:** `pciutils` (описания PCI), `hwdata` (база
USB-идентификаторов), `smartmontools` (wellsensors и S.M.A.R.T. в
wellblock), `nvme-cli` (температуры NVMe), `dmidecode` + `i2c-tools`
(детали памяти через decode-dimms), `util-linux` (lscpu для wellcpu).
Установщик `install.sh` сам подбирает имена пакетов под ваш дистрибутив.

## Лицензия

MIT, кроме таблицы вендоров JEDEC JEP106 (`jedec.sh`), извлечённой
из i2c-tools `decode-dimms` (GPL-2.0, (c) авторы i2c-tools).
Полная атрибуция - в `LICENSE`.
