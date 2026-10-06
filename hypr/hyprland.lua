--
-- Hyprland configuration — entry point.
--
-- Hyprland 0.55 replaced the old `hyprland.conf` (hyprlang) format with Lua;
-- hyprlang is deprecated and gets no new features, so everything lives here now.
-- See https://wiki.hypr.land/Configuring/Start/
--
-- Deployment: two symlinks are needed, because `require` resolves against
-- ~/.config/hypr/ and does NOT follow the entry point's symlink to this repo:
--
--     ln -s ~/dotfiles/hypr/hyprland.lua ~/.config/hypr/hyprland.lua
--     ln -sn ~/dotfiles/hypr/conf        ~/.config/hypr/conf
--
-- Validate any change *before* reloading with:
--     Hyprland --config ~/dotfiles/hypr/hyprland.lua --verify-config
--
-- Order matters: `programs` returns a table the later modules use, and monitors
-- should exist before workspaces are pinned to them.
--

local programs = require("conf.programs")

require("conf.monitors")            -- outputs, scaling, workspace-to-monitor pinning
require("conf.autostart")           -- environment variables + startup processes
require("conf.look")                -- general / decoration / animations / misc
require("conf.input")               -- keyboard, mouse, touchpad
require("conf.binds")(programs)     -- keybindings
require("conf.rules")               -- window rules
