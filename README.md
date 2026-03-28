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

## уровень 4: Hyprland keybinds (тайлинг)

все бинды через `code:` (XKB keycode = evdev + 8), поэтому работают
одинаково на **EN и RU** раскладках.

```
# Физ. QWERTY:  q  w  e  r  t    y  u  i  o  p
# Colemak-DH:   q  w  f  p  b    j  l  u  y  ;
# XKB keycode: 24 25 26 27 28   29 30 31 32 33
#
# Физ. QWERTY:  a  s  d  f  g    h  j  k  l  ;
# Colemak-DH:   a  r  s  t  g    m  n  e  i  o
# XKB keycode: 38 39 40 41 42   43 44 45 46 47
#
# Физ. QWERTY:  z  x  c  v  b    n  m
# Colemak-DH:   z  x  c  d  v    k  h
# XKB keycode: 52 53 54 55 56   57 58
```

### управление окнами

| комбо | физ. клавиша (QWERTY) | Colemak-DH | действие |
|---|---|---|---|
| Super + code:24 | Q | Q | закрыть окно |
| Super + code:25 | W | W | терминал |
| Super + code:26 | E | **F** | фуллскрин |
| Super + code:27 | R | **P** | pseudo-tile |
| Super + code:39 | S | **R** | лаунчер |
| Super + code:40 | D | **S** | скрэтчпад |
| Super + code:41 | F | **T** | toggle split |
| Super + code:56 | B | **V** | плавающее окно |
| Super+Shift + code:24 | Q | Q | выход из Hyprland |
| Alt + Space | — | — | лаунчер (альт.) |

### навигация MNEI (физ. HJKL)

| модификатор | M (code:43) | N (code:44) | E (code:45) | I (code:46) |
|---|---|---|---|---|
| Super | фокус влево | фокус вниз | фокус вверх | фокус вправо |
| Super+Shift | двинуть влево | двинуть вниз | двинуть вверх | двинуть вправо |
| Super+Ctrl | ресайз ← | ресайз ↓ | ресайз ↑ | ресайз → |

стрелки тоже работают как фоллбэк (Super + ←↓↑→).

### воркспейсы

- Super + 1-0 → переключить воркспейс (code:10–19)
- Super + Shift + 1-0 → переместить окно в воркспейс
- Super + scroll → листать воркспейсы

### мышь

- Super + ЛКМ → перетаскивание окна
- Super + ПКМ → ресайз окна

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
├─ XF86Launch7 → evdev → kanata (pass) → Hyprland → layout 1 (RU)
│
└─ Super+code:XX → Hyprland bind → тайлинг (layout-independent)
```

## мёртвые компоненты

- **Toshy** — установлен в `~/.config/toshy/`, все сервисы отключены. не участвует.
- **X11 XKB** (`/etc/X11/xorg.conf.d/00-keyboard.conf`) — на Wayland не используется.
