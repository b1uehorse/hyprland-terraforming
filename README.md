# клавиатурный пайплайн — как всё работает

## железо

| устройство | что это |
|---|---|
| Lily58 Pro | сплит-клавиатура, ZMK, Bluetooth, основная |
| AT Translated Set 2 | встроенная клавиатура Razer Blade Stealth 13 |
| CompX 2.4G Wireless Receiver | беспроводной ресивер |
| Logitech M720 Triathlon | мышь |

## что шлёт Lily58 (ZMK прошивка)

- обычные клавиши → стандартные evdev-коды (QWERTY-позиции)
- XF86Launch6 → переключить на English
- XF86Launch7 → переключить на Русский
- F17 → копировать (через kanata → Ctrl+C)
- F18 → вставить (через kanata → Ctrl+V)

## уровень 1: kanata (evdev → evdev)

сервис: `kanata.service` (systemd, system-level)
конфиг: `~/.config/kanata/kanata.kbd`

```
(defcfg
  process-unmapped-keys yes
  log-layer-changes no
)

(defsrc f15 f16 f17 f18)

(deflayer default
  f15 f16 @cpy @pst
)

(defalias
  cpy (multi lctl c)
  pst (multi lctl b)
)
```

kanata работает на уровне evdev — **до** XKB. имена клавиш в конфиге
соответствуют QWERTY-позициям, не Colemak-DH. поэтому для paste нужен
`lctl b`, а не `lctl v`:

| kanata шлёт | evdev-код | XKB Colemak-DH делает | результат |
|---|---|---|---|
| `lctl c` | KEY_C | → 'c' | Ctrl+C (copy) |
| `lctl b` | KEY_B | → 'v' | Ctrl+V (paste) |
| `lctl v` | KEY_V | → 'd' | Ctrl+D (неправильно!) |

F15/F16 проходят сквозь kanata без изменений — их ловит Hyprland.

## уровень 2: Hyprland XKB (evdev → keysym)

конфиг: `~/.config/hypr/hyprland.conf`

```
input {
  kb_layout = us,ru
  kb_variant = colemak_dh_ortho,
  kb_options =
}
```

- layout 0 (English): Colemak-DH Ortho
- layout 1 (Русский): стандартная ЙЦУКЕН

XKB ремапит evdev-коды в keysym'ы. Colemak-DH реализован здесь,
а не в kanata — так русская раскладка остаётся чистой ЙЦУКЕН.

## уровень 3: Hyprland binds (переключение раскладки)

```
bind = , XF86Launch6, exec, hyprctl switchxkblayout all 0  # English
bind = , XF86Launch7, exec, hyprctl switchxkblayout all 1  # Русский
```

переключение детерминированное — конкретная клавиша = конкретная раскладка,
не toggle. XF86Launch6/7 приходят напрямую с Lily58, kanata их пропускает.

## полный пайплайн

```
Lily58 (ZMK)
│
├─ обычные клавиши → evdev → kanata (pass) → XKB → приложение
│
├─ F17 → evdev → kanata → Ctrl+KEY_C → XKB → Ctrl+C (copy)
├─ F18 → evdev → kanata → Ctrl+KEY_B → XKB → Ctrl+V (paste)
│
├─ XF86Launch6 → evdev → kanata (pass) → Hyprland → layout 0 (EN)
└─ XF86Launch7 → evdev → kanata (pass) → Hyprland → layout 1 (RU)
```

## мёртвые компоненты

- **Toshy** — установлен в `~/.config/toshy/`, все сервисы отключены. не участвует.
- **X11 XKB** (`/etc/X11/xorg.conf.d/00-keyboard.conf`) — на Wayland не используется.
