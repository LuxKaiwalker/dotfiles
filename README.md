# Dotfiles

These are my dotfiles for my hyprland configuration.
They include, most notoriously,

- waybar
- hypr
- nvim

and a few more.

```
dotfiles/
├── hypr/       compositor (Lua) + hypridle
├── waybar/     the 30px vertical bar on the left edge
├── gtklock/    lock screen
├── wofi/       application launcher
├── wlogout/    power menu
├── mako/       notifications
├── fish/       interactive shell
├── bash/       login/compatibility shell
└── nvim/       editor
```

(`t.txt` and `issues` are stray scratch files, not configuration.)

## Deploying

Everything is symlinked out of this repo, so a checkout is the live config.
Whole directories where the app keeps nothing else there:

```sh
ln -sn ~/dotfiles/gtklock ~/.config/gtklock
ln -sn ~/dotfiles/mako    ~/.config/mako
ln -sn ~/dotfiles/wofi    ~/.config/wofi
ln -sn ~/dotfiles/wlogout ~/.config/wlogout
```

Single files where it does — fish keeps `functions/`, `completions/` and its
universal variables next to `config.fish`, nvim keeps lazy.nvim's state next to
`init.lua`:

```sh
ln -s ~/dotfiles/bash/bashrc         ~/.bashrc
ln -s ~/dotfiles/fish/config.fish    ~/.config/fish/config.fish
ln -s ~/dotfiles/nvim/init.lua       ~/.config/nvim/init.lua
ln -s ~/dotfiles/waybar/config.jsonc ~/.config/waybar/config.jsonc
ln -s ~/dotfiles/waybar/style.css    ~/.config/waybar/style.css
ln -s ~/dotfiles/hypr/hypridle.conf  ~/.config/hypr/hypridle.conf
```

Hyprland itself needs two links for one config; see *hypr → Deploying* below.

## hypr

Hyprland 0.55 replaced the `hyprland.conf` (hyprlang) format with Lua, and
hyprlang is deprecated — it gets no new features and will be dropped. The
Hyprland config here is therefore Lua, split into modules:

```
hypr/
├── hyprland.lua        entry point; requires the modules below, in order
├── conf/
│   ├── programs.lua    terminal/browser/... used by binds and autostart
│   ├── monitors.lua    outputs, XWayland scaling, workspace-to-monitor pinning
│   ├── autostart.lua   environment variables + startup processes
│   ├── look.lua        general / decoration / animations / dwindle / misc
│   ├── input.lua       keyboard, pointer, touchpad
│   ├── statusbar.lua   waybar show/hide, and the left window margin with it
│   ├── binds.lua       keybindings
│   └── rules.lua       window rules
└── hypridle.conf       hypridle still uses hyprlang; unchanged
```

The order in `hyprland.lua` is load-bearing: `programs.lua` and `statusbar.lua`
return tables the later modules are handed, monitors have to exist before
workspaces are pinned to them, and `statusbar.lua` reads the gaps `look.lua`
sets.

### Keybindings

`SUPER` is the modifier, and Caps Lock is a second `SUPER` (`caps:super` in
`conf/input.lua`), so every binding below is reachable from the home row.
Programs come from `conf/programs.lua`.

```
SUPER + Return          terminal (konsole)
SUPER + E               file manager (nemo)
SUPER + R               launcher (wofi --show drun)
SUPER + F               browser (firefox)
SUPER + D               discord
SUPER + M               suspend
Print                   region screenshot (~/bin/screenshot select)

SUPER + Q               close window        (Q, to match close-tab reflex)
SUPER + V               toggle floating
SUPER + W               fullscreen
SUPER + A               toggle the status bar
SUPER + SPACE           next keyboard layout (QWERTY <-> Colemak)
SUPER + LMB / RMB       drag to move / resize

SUPER         + hjkl    move focus          (arrow keys work everywhere too)
SUPER + ALT   + hjkl    move the window
SUPER + SHIFT + hjkl    resize by 50px
SUPER         + 1..0    switch to workspace 1-10
SUPER + ALT   + 1..0    send the window to workspace 1-10
```

Volume, brightness and the lid switch are bound to the hardware keys as
`locked`, so they keep working over the lock screen.

### Hiding the status bar

`SUPER+A` toggles waybar. Waybar's own `SIGUSR1` does the hiding, which
releases its exclusive zone, so windows reflow onto the 30px the bar was
holding on the left edge; `general:gaps_out` loses its left gap for as long as
the bar is away, so a hidden bar really does mean 0px between a window and the
left border. `SUPER+W` is fullscreen. See `conf/statusbar.lua`.

The toggle asks the compositor which layers reserve space rather than
remembering its own last state, so it still does the right thing after a
`hyprctl reload` or a `SIGUSR1` sent from elsewhere — and if waybar is not
running at all, it starts it.

One Hyprland quirk worth knowing: dwindle does not re-tile a workspace that has
a fullscreen window on it, so windows there take the new margin once the
fullscreen window is dismissed, not while it is up.

### Monitors

Workspaces 1-5 are pinned to the laptop panel (`eDP-1`), 6-10 to `HDMI-A-1`;
unplugging HDMI moves 6-10 back on its own. A catch-all `output = ""` entry
gives any other display auto-detected settings, so a new dock or a borrowed
projector just works. Modes for the displays this machine actually meets are
kept as comments in `conf/monitors.lua`.

### Deploying

`require` resolves against `~/.config/hypr/` and does *not* follow the entry
point's symlink into this repo, so both of these are needed:

```sh
ln -s  ~/dotfiles/hypr/hyprland.lua ~/.config/hypr/hyprland.lua
ln -sn ~/dotfiles/hypr/conf         ~/.config/hypr/conf
```

### Checking a change before you reload

```sh
Hyprland --config ~/dotfiles/hypr/hyprland.lua --verify-config
```

This parses the config without starting a compositor and reports unknown keys,
bad dispatcher arguments and invalid rule properties by file and line. Worth
running before every `hyprctl reload`.

### Switching between hyprlang and Lua needs a restart, not a reload

Hyprland picks `hyprland.lua` over `hyprland.conf` *once, at process start*, and
reuses that choice for the life of the session. `hyprctl reload` re-reads the
file it already chose — it will not move a running session from one format to
the other. Worse, if the chosen file goes missing, a reload writes a stub
config in its place and the desktop drops to defaults (no `caps:super`, no
binds).

So: never remove the config a running session is using. Add the new one, then
log out and back in.

The old hyprlang config is still in git history:

```sh
git show bb41655:hypr/hyprland.conf
```

A copy currently sits at `~/.config/hypr/hyprland.conf` (untracked) so the
session that predates this migration keeps working. It is ignored on the next
start, since Lua is checked first; delete it once you have relogged in and
confirmed the Lua config behaves.

## waybar

A 30px bar docked to the **left** edge of both outputs, on the `top` layer with
an exclusive zone — which is what `conf/statusbar.lua` takes away when the bar
is hidden. Workspaces sit at the top, the focused window in the middle, the
system modules at the bottom.

Because the bar is vertical, every text-bearing module carries `"rotate": 90`,
and the ones that cannot rotate legibly are reduced to a single glyph instead:
`hyprland/window` rewrites known window titles to one icon per app, and
`custom/net-monitor` is a static glyph. The glyphs are Nerd Font codepoints —
without *JetBrainsMono Nerd Font* (named in `style.css`) the bar is a column of
tofu.

Most modules are click-to-open rather than informational:

```
cpu          -> htop               network      -> nmtui
bluetooth    -> bluetui            wireplumber  -> pavucontrol
net-monitor  -> nload              clock        -> gsimplecal
power        -> wlogout
```

The `.bak`/`.bak2` files next to `config.jsonc` and `style.css` are earlier
iterations of the redesign, kept for reference.

## Lock screen and idle

The lock screen is gtklock (it replaced hyprlock, which kept crashing). Its
wallpaper is per-output CSS in `gtklock/style.css`, keyed by monitor name —
`window#eDP-1`, `window#HDMI-A-1` — so each screen locks to its own image.

`hypr/hypridle.conf` drives the timeline, and every entry guards on
`pgrep -x gtklock` so a second locker is never spawned:

```
 7 min   lock
 8 min   displays off (dpms)
10 min   suspend
```

Suspend from any source — the 10-minute timer, `SUPER+M`, the wlogout menu, the
lid — locks first, through `general.before_sleep_cmd`. Lid close itself is
handled by systemd-logind (`HandleLidSwitch=suspend`), not by hypridle:
hypridle 0.1.8 has no lid listener and silently ignores one.

## Shells

fish is the interactive shell; `bash/bashrc` is kept for login and
compatibility. They have drifted on purpose:

`fish/config.fish` guards each SDK on the directory existing, so an absent
Flutter no longer exports `FLUTTER_HOME` pointing at nothing, and it stopped
sourcing `nvm.sh` at startup — `bass` translating 4.4k lines of nvm cost ~250ms
of *every* shell to produce one PATH entry. The default Node version's `bin` is
added directly, and `nvm` itself is a function that loads the real thing on
first use, so `nvm use 20` still works and pays the 250ms once, in the shell
that asked. That wrapper needs the `bass` fish plugin.

`bash/bashrc` still sources nvm (and ghcup) eagerly. It is only on the login
path, so it has not been given the same treatment.

`fish/fish_variables` is tracked too, since the colour theme lives in fish's
universal variables rather than in `config.fish`.

## nvim

`nvim/init.lua` bootstraps lazy.nvim, maps `jk` and `kj` to Escape with
`timeoutlen` at 300ms, and clears the background on the main highlight groups so
the editor is transparent over the terminal.

Note that nothing calls `require("lazy").setup(...)` yet: the bootstrap clones
lazy.nvim and puts it on the runtimepath, but no plugin specs are declared, so
this is still a near-stock nvim. `lazy-lock.json` and `plugin/` are gitignored.

## Notifications, launcher, power menu

- **mako** — bottom-left, Cozette 11, 10s default timeout, with per-urgency
  border colours and `urgency=high` pinned until dismissed. A few rules are
  filters rather than styling: Firefox notifications are suppressed outright.
  Its `output=DP-2` names a display this setup no longer has (the monitors are
  `eDP-1` and `HDMI-A-1`) — a leftover worth deleting.
- **wofi** — centred 400x300 `drun` launcher, on `SUPER+R`.
- **wlogout** — lock / logout / suspend / hibernate / reboot / shutdown, opened
  from the bar's power glyph. `noise.png` is the texture its `style.css` uses.
