--
-- Environment variables and startup processes.
--
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--

---------------------------
-- Environment variables --
---------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt apps: use the Wayland backend and read their theme from qt6ct.
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Let Electron apps (Discord et al.) pick Wayland themselves. Without this they
-- fall back to XWayland and stutter.
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

---------------
-- Autostart --
---------------

-- The old `exec-once =` lines become one "hyprland.start" handler. This is the
-- documented replacement and it keeps the run-once semantics: the handler does
-- not re-fire when the config is reloaded, so a reload no longer risks spawning
-- a second waybar.
--
-- (The old config ended several of these with a trailing `&`. Hyprland already
-- backgrounds them, so the `&` was a no-op and is dropped here.)
hl.on("hyprland.start", function()
    -- Hand the Wayland session over to dbus and systemd --user, so portals,
    -- screen sharing and user services can see WAYLAND_DISPLAY. Must come
    -- first: everything below inherits from this environment.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Desktop shell: status bar, wallpaper daemon, idle manager, notifications.
    hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("mako")

    -- Polkit agent, so GUI apps can prompt for authentication.
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Clipboard history (cliphist needs one watcher per MIME type).
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Battery alerts, currently off:
    -- hl.exec_cmd("poweralertd")
end)
