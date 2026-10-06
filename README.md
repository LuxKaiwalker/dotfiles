# Dotfiles

These are my dotfiles for my hyprland configuration.
They include, most notoriously,

- waybar
- hypr
- nvim

and a few more.

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
│   ├── binds.lua       keybindings
│   └── rules.lua       window rules
└── hypridle.conf       hypridle still uses hyprlang; unchanged
```

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
