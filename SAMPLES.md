# Live output samples / Живые примеры вывода

Реальный вывод с моей (wellbou) машины (Arch Linux, Xeon E3-1230 V2,
GTX 1050 Ti, два монитора 20" 1600x900) - чтобы до установки было
видно, как выглядит каждый инструмент. 

Real output from the author's machine so you can see exactly what each
tool looks like before installing.

## wellcpu

```sh
$ wellcpu --plain
```

```

  🧠 wellcpu -- Обзор CPU

  ⚙ ПРОЦЕССОР
  🧠 Модель:       Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
  🏛 Архитектура:  x86_64
  🧩 Сокеты:       1
  ⚙ Ядра:         4
  🔗 Потоки:       8
  ⚡ Частота:      3.30 GHz (база) / 3.70 GHz (макс)
  📦 Кэши:         L1d: 128 KiB (4 экземпляра)  L1i: 128 KiB (4 экземпляра)
                   L2: 1 MiB (4 экземпляра)  L3: 8 MiB (1 экземпляр)
  💡 Фичи:         avx sse4_2 sse4_1 aes ssse3
  🛡 Виртуализация: Intel VT-x
  🎚 Режим управления: schedutil
  📈 НАГРУЗКА ЯДЕР / ЧАСТОТА
  CPU0  ████░░░░░░░░░░   30%  @ 2.52 GHz  (schedutil)
  CPU1  ████░░░░░░░░░░   31%  @ 3.21 GHz  (schedutil)
  CPU2  █████░░░░░░░░░   36%  @ 3.50 GHz  (schedutil)
  CPU3  ████░░░░░░░░░░   35%  @ 3.54 GHz  (schedutil)
  CPU4  ████░░░░░░░░░░   31%  @ 3.57 GHz  (schedutil)
  CPU5  ████░░░░░░░░░░   35%  @ 3.53 GHz  (schedutil)
  CPU6  ████░░░░░░░░░░   33%  @ 3.50 GHz  (schedutil)
  CPU7  ████░░░░░░░░░░   30%  @ 3.51 GHz  (schedutil)

  WellCPU v1.0 | 2026-08-26 12:20:39

```

## wellmem

```sh
$ wellmem --plain
```

```

  🧠 wellmem -- Обзор памяти

  🧩 ФИЗИЧЕСКАЯ ПАМЯТЬ (RAM)

  ███████████████████████████████░░░░░░░░░ 78% использовано

  Всего:           7.7 GiB
  Использовано:    6.1 GiB
  Доступно:        1.7 GiB
  Буферы:         68.7 MiB
  Кэш:             1.9 GiB
  Разделяемая:    37.6 MiB
  Свободно:       330.9 MiB

  🔄 ПОДКАЧКА
  █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 3% использовано
  Всего: 23.4 GiB  Использовано: 734.7 MiB  Свободно: 22.7 GiB

  📦 ZRAM -- сжатая RAM
  Размер: 15.4 GiB  Алгоритм: zstd
  Данные: 4 KiB  Сжато: 0 KiB  (Степень: 64.0x)

  WellMem v1.1 | 2026-08-26 12:20:39

```

## wellgpu

```sh
$ wellgpu --plain
```

```

  🎮 wellgpu -- Обзор GPU

  🖥 ВИДЕОАДАПТЕРЫ
  🎮 Шина 0:       MSI GP107 [GeForce GTX 1050 Ti] [1c82]  (NVIDIA Corporation [10de])
       └─ Драйвер: nvidia  01:00.0
  ⚡ ДЕТАЛИ
  🎮 Производитель 0: MSI GeForce GTX 1050 Ti
  💾 Драйвер:      580.173.02
  🌡 Температура:  52°C
  🧩 VRAM:         874 / 4096 MiB  21%
  ⚡ Загрузка:     9%
  🕐 Частоты:      961 MHz  /  mem 3.50 GHz
  🔌 Питание:      ~40.94 W
  🌀 Вентилятор:   0%

  WellGPU v1.0 | 2026-08-26 12:20:39

```

## wellsensors

```sh
$ wellsensors --plain
```

```

  ⚡ wellsensors -- Мониторинг температуры

  🧠 ОБЗОР СИСТЕМЫ
  🖥 CPU:          Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz  (8 потоков)
  📊 Загрузка:     4.99 4.01 3.34  (1/5/15 min)
  🧠 RAM:          6210 MB / 7896 MB  (78%)
  ⏱ Аптайм:       55 minutes
  🔥 ЯДРА CPU
  🔥 Package id 0     60°C  ▁▂▃▄▅
  🌋 Core 0           65°C  ▁▂▃▄▅▆
  🌊 Core 1           49°C  ▁▂▃▄
  🌊 Core 2           48°C  ▁▂▃▄
  🌊 Core 3           49°C  ▁▂▃▄
  🎮 GPU
  🔥 MSI GeForce GTX 1050 Ti   52°C  ▁▂▃▄▅
    ├── Fan: 0%  |  Power: N/A  |  GPU: 961 MHz
    ├── VRAM: 874 / 4096 MiB  |  Util: 9%  |  Mem: 3504 MHz
  🌡 ACPI / МАТЕРИНСКАЯ ПЛАТА
 Нет ACPI-температурных зон
  📡 ТЕПЛОВЫЕ ЗОНЫ
  🔥 x86_pkg_temp     61°C  ▁▂▃▄▅
  🔌 ЧИПСЕНСОРЫ
  ❄ acpitz_0         27°C  ▁▂▃
  ❄ acpitz_1         29°C  ▁▂▃
  🔥 f71869a          53°C  ▁▂▃▄▅
  🌊 f71869a          38°C  ▁▂▃▄
  💾 ХРАНИЛИЩЕ
  ❄ WDC WD5000LPCX-2   28°C  ▁▂▃▄
  ❄ TOSHIBA MK1059GS   33°C  ▁▂▃▄▅
  ❄ WDC WD5000AZRX-0   32°C  ▁▂▃▄▅
  ❄ Apacer AS350 256   33°C  ▁▂▃▄▅
  🌀 ОХЛАЖДЕНИЕ
  💨 Вентилятор1 1477 RPM  (f71869a)
  🌀 Вентилятор:   1 устройств
  ⚙ Состояния CPU: 0 троттлинг
  🧊 Powerclamp:   0 активно
  📋 ACPI-интерфейсы управления вентиляторами: 5
  📈 МИН   27°C   📉 СРД   45°C   🔺 МАКС   57°C

  WellSensors v1.3 | 2026-08-26 12:20:41

```

## wellhw

```sh
$ wellhw --plain
```

```

  🖥 wellhw -- Отчёт о железе

  🧠 CPU
  🧠 CPU:          Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz  (ядер: 4, потоков: 8)
  🎮 GPU
  🎮 GPU:          MSI GP107 [GeForce GTX 1050 Ti] [1c82]  (NVIDIA Corporation [10de])
  🖥 Материнская плата
  🖥 Материнская плата: MSI PH61A-P35 (MS-7732) (v1.0)
  💾 BIOS:         American Megatrends Inc. V2.3 (01/10/2013)
  🧩 ОЗУ
  🧩 ОЗУ:          2× 4 GiB DDR3-1600
       └─ Golden Empire | PN: CL10-11-11 D3-2133
  💿 Накопители
  💿 Накопители:   sda: WDC WD5000LPCX-21VHAT0 (465,8G)
       └─ sdb: TOSHIBA MK1059GSMP (931,5G)
       └─ sdc: WDC WD5000AZRX-00A8LB0 (465,8G)
       └─ sdd: Apacer AS350 256GB (238,5G)
  🌐 Сеть
  🌐 Сеть:         enp0s29u1u5 unknown 16:26:c5:93:ab:8a
       └─ enp6s0 down 8c:89:a5:c7:1b:c0
       └─ tailscale0 unknown 
  🌀 Вентилятор
  🌀 Вентилятор:   Вентилятор 1 1429 RPM (f71882fg.656)
  🔌 PCI-карты расширения
  🔌 0000:01:00.0: VGA compatible controller: NVIDIA Corporation GP107 [GeForce GTX 1050 Ti] (rev a1)
  🔌 0000:01:00.1: Audio device: NVIDIA Corporation GP107GL High Definition Audio Controller (rev a1)

  WellHW v1.3 | 2026-08-26 12:20:41

```

## wellusb

```sh
$ wellusb --plain
```

```


  🔌 wellusb -- Обзор USB-устройств

  📊 Устройства: 11 | БД IDS: загружена


  🏭 Шина 01 USB 2.0 (480 Мбит/с)

  🔌 1d6b:0002 EHCI Host Controller
  Производитель: Linux 7.1.8-arch1-3 ehci_hcd
  Скорость: USB 2.0 (480 Мбит/с)
  Драйвер: hub
  Серийный №: 0000:00:1d.0

  🔌 8087:0024 Integrated Rate Matching Hub
  Производитель: Intel Corp.
  Скорость: USB 2.0 (480 Мбит/с)
  Драйвер: hub
  Тип: Хаб

  🔌 12d1:108a MAO-LX9N
  Производитель: HUAWEI
  Скорость: USB 2.0 (480 Мбит/с)
  Серийный №: LBDYD23810003976

  🔊 0d8c:0014 Zet Koradji
  Производитель: Marow Electronics Inc.
  Скорость: USB 1.1 (12 Мбит/с)
  Драйвер: usbhid
  Серийный №: V1



  🏭 Шина 02 USB 2.0 (480 Мбит/с)

  🔌 1d6b:0002 xHCI Host Controller
  Производитель: Linux 7.1.8-arch1-3 xhci-hcd
  Скорость: USB 2.0 (480 Мбит/с)
  Драйвер: hub
  Серийный №: 0000:05:00.0



  🏭 Шина 03 USB 3.0 (5 Гбит/с)

  🔌 1d6b:0003 xHCI Host Controller
  Производитель: Linux 7.1.8-arch1-3 xhci-hcd
  Скорость: USB 3.0 (5 Гбит/с)
  Драйвер: hub
  Серийный №: 0000:05:00.0



  🏭 Шина 04 USB 2.0 (480 Мбит/с)

  🔌 1d6b:0002 EHCI Host Controller
  Производитель: Linux 7.1.8-arch1-3 ehci_hcd
  Скорость: USB 2.0 (480 Мбит/с)
  Драйвер: hub
  Серийный №: 0000:00:1a.0

  🔌 8087:0024 Integrated Rate Matching Hub
  Производитель: Intel Corp.
  Скорость: USB 2.0 (480 Мбит/с)
  Драйвер: hub
  Тип: Хаб

  🔌 28bd:0062 star06c
  Производитель: XP-PEN
  Скорость: USB 1.1 (12 Мбит/с)
  Драйвер: usbfs
  Тип: Устройство

  🔌 30fa:1701 USB GAMING MOUSE
  Производитель: INSTANT
  Скорость: USB 1.0 (1.5 Мбит/с)
  Драйвер: usbhid
  Тип: Устройство

  🔌 1b1c:1b40 Corsair Gaming K63 Keyboard
  Производитель: Corsair
  Скорость: USB 1.1 (12 Мбит/с)
  Драйвер: usbfs
  Серийный №: 12013028AF3A24015B94C672F5001BC3



  Легенда: ▁ USB 1.1 ▃ USB 2.0 ▅▇ USB 3.0 ▅▇█ USB 3.1+

  WellUSB v2.0 | 2026-08-26 12:20:42
```

## wellpci

```sh
$ wellpci --plain
```

```


  🌉 wellpci -- Обзор PCI-устройств

  📊 Всего устройств: 2 | БД IDS: загружена

  🎮 Видеоконтроллер
  🎮 0000:01:00.0 VGA compatible controller: NVIDIA Corporation… Дрв:nvidia 5.0 GT/s PCIe x16

  🔊 Мультимедиа
  🔊 0000:01:00.1 Audio device: NVIDIA Corporation GP107GL High… Дрв:snd_hda_int… 5.0 GT/s PCIe x16


  WellPCI v2.1 | 2026-08-26 12:20:42
```

## wellblock

```sh
$ wellblock --plain
```

```


  💾 wellblock -- Обзор блочных устройств


  📊 СВОДКА ПО ДИСКАМ

  💿 /dev/sda HDD WDC WD5000LPCX-2 465.8 GB ✓
  Серийный №: WD-WXF1AB6H1CC3
  sda1 465.8 GB exfat -> /mnt/WD500GB

  💿 /dev/sdb HDD TOSHIBA MK1059GS 931.5 GB ✓
  Серийный №: Y13KT0P9T
  sdb1 931.5 GB ext4 -> /mnt/Toshiba

  💿 /dev/sdc HDD WDC WD5000AZRX-0 465.8 GB ✓
  Серийный №: WD-WMC1U5496849
  sdc1 465.8 GB ntfs -> /mnt/Information

  ⚡ /dev/sdd SSD Apacer AS350 256 238.5 GB ✓
  Серийный №: A472071B050C00656487
  sdd1 1.0 GB vfat -> /boot
  sdd2 237.5 GB ext4 -> /

  🔄 ВИРТУАЛЬНЫЕ / LOOP

  🔄 zram0 15.4 GB



  📊 Итого: 4 дисков | 5 разделов | 2101.5 GB

  💡 Подробно о диске: wellblock [N|устройство] -- напр. 'wellblock 0' или 'wellblock sda'

  WellBlock v1.1 | 2026-08-26 12:20:44
```

## wellmod

```sh
$ wellmod --plain
```

```


  📦 wellmod -- Обзор модулей ядра

  📊 Всего модулей: 137 | Общий размер: 121.6 MB

  🏆 ТОП-10 ПО РАЗМЕРУ

  1. 🎮 nvidia 106.5 MB ×718
  2. 🎮 nvidia_uvm 3.7 MB
  3. 🎮 nvidia_modeset 1.8 MB ×52
  4. 🧠 kvm 1.4 MB ×1
  5. 🔊 snd_usb_audio 612.0 KB ×1
  6. 🧠 kvm_intel 520.0 KB
  7. 📦 bridge 456.0 KB
  8. 🌐 nf_tables 392.0 KB ×1018
  9. 🧠 intel_uncore 276.0 KB
  10. 📦 overlay 248.0 KB

  🎮 GPU/DRI
  🎮 nvidia_drm 148.0 KB
  🎮 nvidia_uvm 3.7 MB
  🎮 nvidia_modeset 1.8 MB
  🎮 nvidia 106.5 MB

  🔊 Аудио
  🔊 snd_seq_dummy 12.0 KB
  🔊 snd_hrtimer 12.0 KB
  🔊 snd_seq 132.0 KB
  🔊 snd_hda_codec_alc882 20.0 KB
  🔊 snd_hda_codec_realtek_lib 64.0 KB
  🔊 snd_usb_audio 612.0 KB
  🔊 snd_hda_codec_generic 112.0 KB
  🔊 snd_hda_codec_nvhdmi 16.0 KB
  🔊 snd_usbmidi_lib 52.0 KB
  🔊 snd_hda_codec_hdmi 60.0 KB
  🔊 snd_ump 40.0 KB
  🔊 snd_rawmidi 56.0 KB
  🔊 snd_seq_device 16.0 KB
  🔊 snd_hda_intel 72.0 KB
  🔊 snd_hda_codec 224.0 KB
  🔊 snd_hda_core 148.0 KB
  🔊 snd_intel_dspcfg 48.0 KB
  🔊 snd_intel_sdw_acpi 16.0 KB
  🔊 snd_hwdep 24.0 KB
  🔊 snd_pcm 216.0 KB
  🔊 snd_timer 56.0 KB
  🔊 soundcore 16.0 KB

  🔌 USB
  🔌 usbnet 64.0 KB
  🔌 uas 32.0 KB
  🔌 usb_storage 92.0 KB

  📁 Файловая система
  📁 vfat 28.0 KB

  🌐 Сеть
  🌐 ip_set 68.0 KB
  🌐 nft_nat 12.0 KB
  🌐 nft_masq 12.0 KB
  🌐 nft_fib_inet 12.0 KB
  🌐 nft_fib_ipv4 12.0 KB
  🌐 nft_fib_ipv6 12.0 KB
  🌐 nft_fib 12.0 KB
  🌐 nft_reject_inet 12.0 KB
  🌐 nf_reject_ipv4 12.0 KB
  🌐 nf_reject_ipv6 24.0 KB
  🌐 nft_reject 12.0 KB
  🌐 nft_compat 20.0 KB
  🌐 nft_queue 12.0 KB
  🌐 nft_ct 32.0 KB
  🌐 nft_chain_nat 12.0 KB
  🌐 nf_nat 64.0 KB
  🌐 nf_conntrack 204.0 KB
  🌐 nf_defrag_ipv6 24.0 KB
  🌐 nf_defrag_ipv4 12.0 KB
  🌐 nf_tables 392.0 KB

  📶 Bluetooth
  📶 rfkill 44.0 KB

  🖥 Дисплей
  🖥 drm_ttm_helper 20.0 KB
  🖥 video 80.0 KB

  🔗 Шина
  🔗 i2c_i801 40.0 KB
  🔗 i2c_smbus 20.0 KB
  🔗 i2c_mux 20.0 KB
  🔗 i2c_dev 28.0 KB

  🧠 CPU/Вирт.
  🧠 intel_rapl_msr 24.0 KB
  🧠 intel_rapl_common 52.0 KB
  🧠 intel_powerclamp 24.0 KB
  🧠 kvm_intel 520.0 KB
  🧠 kvm 1.4 MB
  🧠 intel_cstate 20.0 KB
  🧠 intel_uncore 276.0 KB
  🧠 intel_pmc_bxt 16.0 KB
  🧠 intel_oc_wdt 12.0 KB

  📦 Прочее
  📦 tcp_diag 20.0 KB
  📦 udp_diag 12.0 KB
  📦 inet_diag 20.0 KB
  📦 rndis_host 28.0 KB
  📦 cdc_ether 28.0 KB
  📦 mii 20.0 KB
  📦 sr_mod 32.0 KB
  📦 cdrom 84.0 KB
  📦 bridge 456.0 KB
  📦 stp 12.0 KB
  📦 llc 16.0 KB
  📦 xfrm_user 80.0 KB
  📦 xfrm_algo 16.0 KB
  📦 xt_set 24.0 KB
  📦 xt_addrtype 12.0 KB
  📦 xt_connmark 12.0 KB
  📦 xt_conntrack 12.0 KB
  📦 xt_MASQUERADE 16.0 KB
  📦 xt_tcpudp 20.0 KB
  📦 xt_mark 12.0 KB
  📦 x_tables 72.0 KB
  📦 tun 72.0 KB
  📦 nfnetlink_queue 36.0 KB
  📦 nfnetlink 20.0 KB
  📦 overlay 248.0 KB
  📦 uinput 28.0 KB
  📦 f71882fg 52.0 KB
  📦 exfat 124.0 KB
  📦 fat 112.0 KB
  📦 x86_pkg_temp_thermal 16.0 KB
  📦 coretemp 24.0 KB
  📦 at24 28.0 KB
  📦 irqbypass 16.0 KB
  📦 ppdev 24.0 KB
  📦 aesni_intel 104.0 KB
  📦 mei_hdcp 28.0 KB
  📦 mei_pxp 20.0 KB
  📦 gf128mul 12.0 KB
  📦 aead 16.0 KB
  📦 rapl 20.0 KB
  📦 pcspkr 12.0 KB
  📦 iTCO_wdt 16.0 KB
  📦 r8169 160.0 KB
  📦 gpio_ich 16.0 KB
  📦 mc 96.0 KB
  📦 realtek 64.0 KB
  📦 phy_package 16.0 KB
  📦 mdio_devres 12.0 KB
  📦 parport_pc 72.0 KB
  📦 mousedev 28.0 KB
  📦 mei_me 60.0 KB
  📦 joydev 28.0 KB
  📦 parport 88.0 KB
  📦 libphy 224.0 KB
  📦 snd 156.0 KB
  📦 mei 212.0 KB
  📦 mdio_bus 28.0 KB
  📦 mac_hid 12.0 KB
  📦 tcp_bbr 24.0 KB
  📦 sch_fq 28.0 KB
  📦 ntsync 20.0 KB
  📦 crypto_user 16.0 KB
  📦 zram 72.0 KB
  📦 842_decompress 20.0 KB
  📦 842_compress 24.0 KB
  📦 lz4hc_compress 20.0 KB
  📦 lz4_compress 24.0 KB
  📦 lpc_ich 28.0 KB
  📦 hid_cmedia 12.0 KB
  📦 ttm 148.0 KB
  📦 wmi 40.0 KB



  Размер: <64КБ <256КБ <1МБ >1МБ

  WellMod v1.0 | 2026-08-26 12:20:45
```

## wellper

```sh
$ wellper --plain
```

```

  🎮  wellper -- Отчёт о периферии 


  Устройства: 5  |  Мониторы: 2  |  Звук: 3  |  PCI-устройства: 2

  🖱 Устройства ввода (3)
   🎨 star06c · Графический планшет · USB 1.1 (12 Мбит/с)
       └─ Производитель: XP-PEN
   🖱 USB GAMING MOUSE · Мышь · USB 1.0 (1.5 Мбит/с)
       └─ Производитель: INSTANT
   ⌨ Corsair Gaming K63 Keyboard · Клавиатура · USB 1.1 (12 Мбит/с)
       └─ Производитель: Corsair
  📷 Мультимедиа (1)
   🎧 Zet Koradji · Аудио · USB 1.1 (12 Мбит/с)
       └─ Производитель: Marow Electronics Inc.
  🧩 Прочие устройства (1)
   📱 MAO-LX9N · Телефон · USB 2.0 (480 Мбит/с)
       └─ Производитель: HUAWEI
  🖥 Мониторы (2)
   🖥 VA2038 SERIES 1600x900
       ├─ Производитель: ViewSonic
       ├─ Интерфейс: DVI
       └─ PPI: 91.8
   🖥 E2041 1600x900
       ├─ Производитель: LG
       ├─ Интерфейс: HDMI
       └─ PPI: 91.8
  🔊 Звук (3)
   🔊 [0] HDA Intel PCH
   🔊 [1] HDA NVidia
   🔊 [2] Zet Koradji
  🔌 PCI-устройства (2)
   🔌 0000:01:00.0  VGA compatible controller: NVIDIA Corporation GP107 [GeForce GTX 1050 Ti] (rev a1)
   🔌 0000:01:00.1  Audio device: NVIDIA Corporation GP107GL High Definition Audio Controller (rev a1)

  WellPer v1.0 | 2026-08-26 12:20:45

```

## wellnet

```sh
$ wellnet --plain
```

```

  📡 wellnet -- Обзор сети

  🛰 Подключение
 🛰  Основной канал: enp0s29u1u5 (раздача через USB)
       └─ 🚪  Шлюз: 192.168.42.129 (46:53:42:e7:63:6c)
       └─ 🧭  DNS: 127.0.0.53
  🔌 Интерфейсы
 🔌  docker0 [down]  virtual  1a:18:a0:27:73:22
 🔌  enp0s29u1u5 [up]  usb_tether  16:26:c5:93:ab:8a
 🔌  enp6s0 [down]  ethernet  8c:89:a5:c7:1b:c0
 🔌  lo [up]  loopback  00:00:00:00:00:00
 🔌  tailscale0 [up]  vpn  
  🌐 Адреса
       └─ 🌐  lo  UNKNOWN 127.0.0.1/8 ::1/128
       └─ 🌐  enp6s0  DOWN
       └─ 🌐  tailscale0  UNKNOWN 100.78.242.14/32 fd7a:115c:a1e0::3932:f20f/128 fe80::eeed:9aae:3182:c69c/64
       └─ 🌐  docker0  DOWN 172.17.0.1/16
       └─ 🌐  enp0s29u1u5  UNKNOWN 192.168.42.163/24 fe80::e98:1bcf:a6c3:53d2/64
  📶 Wi-Fi
 Wi-Fi интерфейсов нет
  🚪 Маршруты
 🚪  default via 192.168.42.129 dev enp0s29u1u5 proto dhcp src 192.168.42.163 metric 100 
       └─ 172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown 
       └─ 192.168.42.0/24 dev enp0s29u1u5 proto kernel scope link src 192.168.42.163 metric 100 
  👂 Прослушиваемые порты
 👂  Слушателей: TCP 0 · UDP 11
  📊 Трафик (с загрузки)
 📊  enp0s29u1u5: ↓ приём 215 MiB · ↑ отдача 111 MiB
 📊  tailscale0: ↓ приём 86 B · ↑ отдача 3 KiB
 📊  enp6s0: ↓ приём 0 B · ↑ отдача 0 B
 📊  docker0: ↓ приём 0 B · ↑ отдача 0 B
 Σ  net_total: ↓ 215 MiB · ↑ 111 MiB

  WellNet v1.0 | 2026-08-26 12:20:46

```

## wellpower

```sh
$ wellpower --plain
```

```

  🔋 wellpower -- Обзор питания

  🔋 Батарея
 батарея не найдена
  ⚡ Сеть
 нет данных о питании
  📉 Текущее потребление
 потребление недоступно
  🎚 Пороги заряда
 не поддерживается
  ⚙ Управление питанием
 ⚙ менеджер профилей не найден

  WellPower v1.0 | 2026-08-26 12:20:46

```

## welldoctor

```sh
$ welldoctor --plain
```

```

  🩺 welldoctor -- Проверка здоровья системы


  ✘ S.M.A.R.T. ПРОВАЛЕН: /dev/sdb
  ✔ Температура CPU в норме: 58°C
  ⚠ Диск заполнен сильно: / 86%
  ✔ Сбойных systemd-юнитов нет
  · Оставшийся конфиг: /etc/tpm2-tss/fapi-profiles/P_ECCP384SHA384.json.pacnew
  · Оставшийся конфиг: /etc/tpm2-tss/fapi-profiles/P_RSA3072SHA384.json.pacnew
  · Оставшийся конфиг: /etc/systemd/resolved.conf.pacnew
  · Оставшийся конфиг: /etc/lightdm/lightdm.conf.pacnew
  · Оставшийся конфиг: /etc/pacman.d/mirrorlist.pacnew
  · и ещё остатков: +1
  ⚠ Хвосты pacnew/pacsave: 6 (запустите pacdiff)
  ⚠ Осиротевшие пакеты: 17

  welldoctor: 1 критично, 3 предупреждений

  WellDoctor v1.0 | 2026-08-26 12:20:46

```

## wellup

```sh
$ wellup --check  --plain
```

```

  🔄 wellup -- Обновление системы

  💻 Система
Пакетный менеджер  pacman
ОС  Arch Linux
Режим  только проверка
  📦 Доступные обновления: 307
abseil-cpp  20260526.0-2 -> 20260817.0-1
akonadi  26.04.3-1 -> 26.08.0-1
akonadi-contacts  26.04.3-1 -> 26.08.0-1
android-tools  37.0.0-2 -> 37.0.0-3
archlinux-appstream-data  20260722-1 -> 20260821-1
arianna  26.04.3-1 -> 26.08.0-1
ark  26.04.3-1 -> 26.08.0-1
attica  6.28.0-1 -> 6.29.0-1
baloo  6.28.0-1 -> 6.29.0-2
baloo-widgets  26.04.3-1 -> 26.08.0-1
bind  9.20.26-1 -> 9.20.27-1
bluez-qt  6.28.0-1 -> 6.29.0-1
boost-libs  1.91.0-2 -> 1.92.0-1
breeze-icons  6.28.0-1 -> 6.29.0-1
code  1.131.0-1 -> 1.131.0-2
colord-kde  26.04.3-1 -> 26.08.0-1
containerd  2.3.3-1 -> 2.3.4-1
cpupower  7.1.8-1 -> 7.2-1
distro-info-data  2026.07.30-1 -> 2026.08.20-1
dkms  3.4.2-1 -> 3.4.3-2
dolphin  26.04.3-1 -> 26.08.0-4
electron42  42.9.0-1 -> 42.9.3-1
elfutils  0.195-8 -> 0.196-1
engrampa  1.28.3-1 -> 1.28.5-1
fastfetch  2.67.0-1 -> 2.67.1-1
filelight  26.04.3-1 -> 26.08.0-1
firefox  153.0.4-1 -> 154.0.1-1
firewalld  2.5.1-1 -> 2.5.1-2
fontconfig  2:2.18.3-1 -> 2:2.18.3-2
frameworkintegration  6.28.0-1 -> 6.29.0-1
francis  26.04.3-1 -> 26.08.0-1
frei0r-plugins  3.2.3-2 -> 3.5.0-1
fuse2  2.9.9-5 -> 2.9.9-6
github-cli  2.97.0-1 -> 2.98.0-1
godot  4.7.1-1 -> 4.7.2-1
gpu-screen-recorder  6.0.0-1 -> 6.0.1-1
grantleetheme  26.04.3-1 -> 26.08.0-1
graphviz  15.1.1-1 -> 16.0.0-1
gst-libav  1.28.6-1 -> 1.28.6-2
gst-plugins-bad-libs  1.28.6-1 -> 1.28.6-2
gst-plugins-base  1.28.6-1 -> 1.28.6-2
gst-plugins-base-libs  1.28.6-1 -> 1.28.6-2
gst-plugins-good  1.28.6-1 -> 1.28.6-2
gst-plugins-ugly  1.28.6-1 -> 1.28.6-2
gstreamer  1.28.6-1 -> 1.28.6-2
gwenview  26.04.3-1 -> 26.08.0-1
htop  3.5.2-1 -> 3.5.3-1
iana-etc  20260530-1 -> 20260617-1
imagemagick  7.1.2.29-2 -> 7.1.2.30-1
imath  3.2.2-6 -> 3.2.3-1
innoextract  1.9-16 -> 1.9-17
iproute2  7.1.0-1 -> 7.2.0-1
isoimagewriter  26.04.3-1 -> 26.08.0-1
jansson  2.15.0-1 -> 2.15.1-1
jdk21-openjdk  21.0.12.u8-1 -> 21.0.12.1.u1-1
kaccounts-integration  26.04.3-1 -> 26.08.0-1
kalk  26.04.3-1 -> 26.08.0-1
kalm  26.04.3-1 -> 26.08.0-1
kamera  26.04.3-1 -> 26.08.0-1
karchive  6.28.0-1 -> 6.29.0-1
kate  26.04.3-1 -> 26.08.0-1
kauth  6.28.0-1 -> 6.29.0-1
kbackup  26.04.3-1 -> 26.08.0-1
kbookmarks  6.28.0-1 -> 6.29.0-1
kcalc  26.04.3-1 -> 26.08.0-1
kcalendarcore  6.28.0-1 -> 6.29.0-1
kcharselect  26.04.3-1 -> 26.08.0-1
kclock  26.04.3-1 -> 26.08.0-1
kcmutils  6.28.0-1 -> 6.29.0-1
kcodecs  6.28.0-1 -> 6.29.0-1
kcolorchooser  26.04.3-1 -> 26.08.0-1
kcolorscheme  6.28.0-1 -> 6.29.0-1
kcompletion  6.28.0-1 -> 6.29.0-1
kconfig  6.28.0-1 -> 6.29.0-1
kconfigwidgets  6.28.0-1 -> 6.29.0-1
kcontacts  1:6.28.0-1 -> 1:6.29.0-1
kcoreaddons  6.28.0-1 -> 6.29.0-1
kcrash  6.28.0-1 -> 6.29.0-1
kcron  26.04.3-1 -> 26.08.0-1
kdbusaddons  6.28.0-1 -> 6.29.0-1
kde-graphics-meta  25.08-1 -> 26.08-1
kde-inotify-survey  26.04.3-1 -> 26.08.0-1
kde-system-meta  25.08-1 -> 26.08-1
kde-utilities-meta  25.08-1 -> 26.08-1
kdebugsettings  26.04.3-1 -> 26.08.0-1
kdeclarative  6.28.0-1 -> 6.29.0-1
kded  6.28.0-1 -> 6.29.0-1
kdegraphics-mobipocket  26.04.3-1 -> 26.08.0-1
kdegraphics-thumbnailers  26.04.3-1 -> 26.08.0-1
kdenlive  26.04.3-2 -> 26.08.0-1
kdeplasma-addons  6.7.4-1 -> 6.7.4-3
kdesu  6.28.0-1 -> 6.29.0-1
kdf  26.04.3-1 -> 26.08.0-1
kdialog  26.04.3-1 -> 26.08.0-1
kdnssd  6.28.0-1 -> 6.29.0-1
kdoctools  6.28.0-1 -> 6.29.0-1
keditbookmarks  26.04.3-1 -> 26.08.0-1
keysmith  26.04.3-1 -> 26.08.0-1
kfilemetadata  6.28.0-2 -> 6.29.0-1
kfind  26.04.3-1 -> 26.08.0-1
kglobalaccel  6.28.0-1 -> 6.29.0-1
kgpg  26.04.3-1 -> 26.08.0-1
kgraphviewer  26.04.3-1 -> 26.08.0-1
kguiaddons  6.28.0-1 -> 6.29.0-1
khelpcenter  26.04.3-1 -> 26.08.0-1
kholidays  1:6.28.0-1 -> 1:6.29.0-1
ki18n  6.28.0-1 -> 6.29.0-1
kiconthemes  6.28.0-1 -> 6.29.0-1
kidletime  6.28.0-1 -> 6.29.0-1
kimageformats  6.28.1-1 -> 6.29.0-1
kimagemapeditor  26.04.3-1 -> 26.08.0-1
kio  6.28.0-1 -> 6.29.0-2
kio-admin  26.04.3-1 -> 26.08.0-1
kio-extras  26.04.3-1 -> 26.08.0-1
kirigami  6.28.0-1 -> 6.29.0-1
kitemmodels  6.28.0-1 -> 6.29.0-1
kitemviews  6.28.0-1 -> 6.29.0-1
kjobwidgets  6.28.0-1 -> 6.29.0-1
kjournald  26.04.3-1 -> 26.08.0-1
kmime  1:6.28.0-1 -> 1:6.29.0-2
knewstuff  6.28.0-1 -> 6.29.0-1
knotifications  6.28.0-1 -> 6.29.0-1
knotifyconfig  6.28.0-1 -> 6.29.0-1
koko  26.04.3-1 -> 26.08.0-1
kolourpaint  26.04.3-1 -> 26.08.0-1
kongress  26.04.3-1 -> 26.08.0-1
konsole  26.04.3-1 -> 26.08.0-1
kopeninghours  26.04.3-1 -> 26.08.0-1
kosmindoormap  26.04.3-1 -> 26.08.0-2
kpackage  6.28.0-1 -> 6.29.0-1
kparts  6.28.0-1 -> 6.29.0-1
kpmcore  26.04.3-1 -> 26.08.0-1
kpty  6.28.0-1 -> 6.29.0-1
kpublictransport  26.04.3-1 -> 26.08.0-1
kquickcharts  6.28.0-1 -> 6.29.0-1
krecorder  26.04.3-1 -> 26.08.0-1
kruler  26.04.3-1 -> 26.08.0-1
krunner  6.28.0-1 -> 6.29.0-1
ksanecore  26.04.3-1 -> 26.08.0-1
kservice  6.28.0-1 -> 6.29.0-1
kstatusnotifieritem  6.28.0-1 -> 6.29.0-1
ksvg  6.28.0-1 -> 6.29.0-1
ksystemlog  26.04.3-1 -> 26.08.0-1
kteatime  26.04.3-1 -> 26.08.0-1
ktexteditor  6.28.0-1 -> 6.29.0-1
ktexttemplate  6.28.0-1 -> 6.29.0-1
ktextwidgets  6.28.0-1 -> 6.29.0-1
ktimer  26.04.3-1 -> 26.08.0-1
ktrip  26.04.3-1 -> 26.08.0-1
kunitconversion  6.28.0-1 -> 6.29.0-1
kuserfeedback  6.28.0-1 -> 6.29.0-1
kwallet  6.28.0-1 -> 6.29.0-1
kwalletmanager  26.04.3-1 -> 26.08.0-1
kweather  26.04.3-1 -> 26.08.0-1
kweathercore  26.04.3-1 -> 26.08.0-1
kwidgetsaddons  6.28.0-1 -> 6.29.0-1
kwin  6.7.4-5 -> 6.7.4-7
kwin-x11  6.7.4-1 -> 6.7.4-3
kwindowsystem  6.28.0-1 -> 6.29.0-1
kxmlgui  6.28.0-1 -> 6.29.0-1
layer-shell-qt  6.7.4-1 -> 6.7.4-2
ldb  2:4.24.5-1 -> 2:4.24.6-1
lib32-libelf  0.195-1 -> 0.196-2
lib32-libice  1.1.1-2 -> 1.1.2-1
lib32-libxfixes  6.0.1-2 -> 6.0.2-1
lib32-libxrender  0.9.11-2 -> 0.9.12-1
lib32-libxxf86vm  1.1.5-2 -> 1.1.7-1
lib32-mesa  1:26.1.7-1 -> 1:26.2.1-1
lib32-openssl  1:3.6.3-1 -> 1:3.6.4-1
libblake3  1.8.4-1 -> 1.8.7-1
libcmis  0.6.3-1 -> 0.6.3-2
libdbusmenu-glib  18.10.20180917-1 -> 18.10.20180917-2
libdbusmenu-gtk3  18.10.20180917-1 -> 18.10.20180917-2
libdeflate  1.25-1 -> 1.26-1
libelf  0.195-8 -> 0.196-1
libevdev  1.13.6-1 -> 1.13.7-1
libical  4.0.4-1 -> 4.0.5-1
libixion  0.20.0-7 -> 0.20.0-8
libkdcraw  26.04.3-1 -> 26.08.0-1
libkexiv2  26.04.3-1 -> 26.08.0-1
libksane  26.04.3-1 -> 26.08.0-1
libmysofa  1.3.4-1 -> 1.3.5-1
libnm  1.58.0-1 -> 1.58.1-1
libopenmpt  0.8.7-1 -> 0.8.8-1
liborcus  0.21.0-6 -> 0.21.0-7
libreoffice-fresh  26.2.5-1 -> 26.2.5-3
libslirp  4.9.3-1 -> 4.9.4-1
libvlc  3.0.23_2-10 -> 3.0.23_2-11
libwbclient  2:4.24.5-1 -> 2:4.24.6-1
libyuv  r2426+464c51a03-1 -> r2921+644251f25-1
lightdm  1:1.33.0-1 -> 1:1.33.1-1
linux  7.1.8.arch1-3 -> 7.1.9.arch1-2
linux-api-headers  7.1-1 -> 7.2-1
linux-headers  7.1.8.arch1-3 -> 7.1.9.arch1-2
lua54  5.4.8-6 -> 5.4.9-1
luajit  2.1.1785763465+1edc3e5-1 -> 2.1.1787165859+1ee778a-1
mailcap  2.1.54-2 -> 2.1.54-3
markdownpart  26.04.3-1 -> 26.08.0-1
mesa  1:26.1.7-1 -> 1:26.2.1-1
modemmanager-qt  6.28.0-1 -> 6.29.0-1
neovim  0.12.4-1 -> 0.12.5-1
networkmanager  1.58.0-1 -> 1.58.1-1
networkmanager-qt  6.28.0-1 -> 6.29.0-1
nmap  7.99-3 -> 7.991-1
obs-studio  32.2.1-7 -> 32.2.2-1
okular  26.04.3-1 -> 26.08.0-2
opencode  1.18.18-1 -> 1.18.23-1
openexr  3.4.14-1 -> 3.4.15-1
ostree  2026.3-1 -> 2026.4-1
oxygen-icons  1:6.28.0-1 -> 1:6.29.0-1
partitionmanager  26.04.3-1 -> 26.08.0-1
perl-dbi  1.651-1 -> 1.652-1
plasma-integration  6.7.4-1 -> 6.7.4-5
plasma-workspace  6.7.4-1 -> 6.7.4-3
poppler  26.07.0-1 -> 26.08.0-1
poppler-glib  26.07.0-1 -> 26.08.0-1
poppler-qt6  26.07.0-1 -> 26.08.0-1
powerdevil  6.7.4-1 -> 6.7.4-3
prison  6.28.0-1 -> 6.29.0-1
protobuf  35.1-1 -> 35.1-2
protobuf-c  1.5.2-12 -> 1.5.2-13
purpose  6.28.0-1 -> 6.29.0-1
python-filelock  3.29.3-1 -> 3.29.4-1
python-firewall  2.5.1-1 -> 2.5.1-2
python-idna  3.18-1 -> 3.19-1
python-platformdirs  4.11.2-1 -> 4.11.3-1
python-sentry_sdk  2.66.1-1 -> 2.68.0-1
qpdf  12.3.2-2 -> 12.4.0-1
qqc2-desktop-style  6.28.0-1 -> 6.29.0-2
qrca  26.04.3-1 -> 26.08.0-1
qt6-5compat  6.11.1-1 -> 6.11.2-1
qt6-base  6.11.1-1 -> 6.11.2-2
qt6-charts  6.11.1-1 -> 6.11.2-1
qt6-declarative  6.11.1-3 -> 6.11.2-1
qt6-httpserver  6.11.1-1 -> 6.11.2-1
qt6-imageformats  6.11.1-1 -> 6.11.2-1
qt6-location  6.11.1-1 -> 6.11.2-1
qt6-multimedia  6.11.1-2 -> 6.11.2-1
qt6-multimedia-ffmpeg  6.11.1-2 -> 6.11.2-1
qt6-networkauth  6.11.1-1 -> 6.11.2-1
qt6-positioning  6.11.1-1 -> 6.11.2-1
qt6-quick3d  6.11.1-1 -> 6.11.2-1
qt6-quicktimeline  6.11.1-1 -> 6.11.2-1
qt6-sensors  6.11.1-1 -> 6.11.2-1
qt6-shadertools  6.11.1-1 -> 6.11.2-1
qt6-speech  6.11.1-1 -> 6.11.2-1
qt6-svg  6.11.1-1 -> 6.11.2-1
qt6-tools  6.11.1-4 -> 6.11.2-1
qt6-translations  6.11.1-1 -> 6.11.2-1
qt6-virtualkeyboard  6.11.1-1 -> 6.11.2-1
qt6-wayland  6.11.1-1 -> 6.11.2-1
qt6-webchannel  6.11.1-1 -> 6.11.2-1
qt6-webengine  6.11.1-5 -> 6.11.2-1
qt6-websockets  6.11.1-1 -> 6.11.2-1
qt6-webview  6.11.1-1 -> 6.11.2-1
re2  2:2025.11.05-5 -> 2:2025.11.05-6
rhythmbox  3.5.0-1 -> 3.5.1-1
signon-kwallet-extension  26.04.3-1 -> 26.08.0-1
simdjson  1:4.6.7-1 -> 1:4.6.8-1
skanlite  26.04.3-1 -> 26.08.0-1
skanpage  26.04.3-1 -> 26.08.0-1
smbclient  2:4.24.5-1 -> 2:4.24.6-1
solid  6.28.0-1 -> 6.29.0-1
sonnet  6.28.0-1 -> 6.29.0-1
source-highlight  3.1.9-18 -> 3.1.9-19
suitesparse  7.13.0-1 -> 7.14.0-1
svgpart  26.04.3-1 -> 26.08.0-1
sweeper  26.04.3-1 -> 26.08.0-1
syndication  6.28.0-1 -> 6.29.0-1
syntax-highlighting  6.28.1-1 -> 6.29.0-1
tailscale  1.102.2-1 -> 1.102.3-1
tar  1.35-3 -> 1.35-5
telegram-desktop  7.0.9-2 -> 7.0.9-4
telly-skout  26.04.3-1 -> 26.08.0-1
threadweaver  6.28.0-1 -> 6.29.0-1
ttf-jetbrains-mono-nerd  3.5.0-1 -> 3.5.1-2
vlc-plugin-a52dec  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-alsa  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-archive  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-dav1d  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-dbus  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-dbus-screensaver  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-faad2  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-flac  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-gnutls  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-inflate  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-journal  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-jpeg  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-matroska  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-mpg123  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-ogg  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-opus  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-png  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-shout  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-speex  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-tag  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-theora  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-twolame  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-vorbis  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-vpx  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugin-xml  3.0.23_2-10 -> 3.0.23_2-11
vlc-plugins-base  3.0.23_2-10 -> 3.0.23_2-11
webkitgtk-6.0  2.52.5-2 -> 2.52.6-1
wine  11.15-1 -> 11.16-1
yakuake  26.04.3-1 -> 26.08.0-1
yt-dlp  2026.07.04-1 -> 2026.08.19-1
zip  3.0-13 -> 3.0-14

  WellUp v1.0 | 2026-08-26 12:20:47

```

## wellfetch

```sh
$ wellfetch --text
```

```
◉ Пользователь: wellbou_@lor
◆ ОС: Arch Linux (x86_64)
◈ Ядро: 7.1.8-arch1-3
◔ Аптайм: 55m · загрузка 2026-08-26 11:25
▚ Процессор: Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
      4 ядра / 8 потоков @ 3500 МГц · нагрузка 4.54
▞ Видеокарта: GP107 [GeForce GTX 1050 Ti] · 4 GiB
▤ Память: 6.1 GiB / 7.7 GiB (79%)
▣ Разрешение: 1600x900
```

## статус-бары

```sh
$ wellcpu --short && wellmem --short && wellsensors --short && wgpu --short && wnet --short && wdoc --short
```

```
30%
6.1/7.7GiB
58°C
52°C 34%
enp0s29u1u5:usb_tether
КРИТИЧНО 45/100 (C1 W3)
```
