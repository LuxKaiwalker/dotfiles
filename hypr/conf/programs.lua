--
-- Programs launched from keybinds and autostart.
--
-- This replaces the old hyprlang `$terminal = konsole` variables. Keeping them
-- in one table means a binding and its program can never drift apart, and
-- swapping a terminal/browser is a one-line change here rather than a grep.
--
return {
    terminal     = "konsole",
    fileManager  = "nemo",
    menu         = "wofi --show drun",
    browser      = "firefox",
    discord      = "discord",

    -- Suspend. Note this is the *manual* path (SUPER+M); idle- and lid-driven
    -- suspend are owned by hypridle.conf and systemd-logind respectively.
    suspend      = "systemctl suspend",

    -- grim + slurp wrapper, see ~/bin/screenshot
    screenshot   = "~/bin/screenshot select",
}

-- If Discord ever needs to be forced onto Wayland again, the old wrapper was
-- /home/vincent/.local/bin/discord-canary-wayland. ELECTRON_OZONE_PLATFORM_HINT
-- in conf/autostart.lua made it unnecessary.
