--
-- Keybindings.
--
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- Returns a function so the entry point can inject conf/programs.lua rather
-- than this module reaching for a global.
--
return function(programs)

local MOD = "SUPER" -- also produced by Caps Lock, see conf/input.lua

------------------------
-- Launching programs --
------------------------

hl.bind(MOD .. " + Return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(MOD .. " + E",      hl.dsp.exec_cmd(programs.fileManager))
hl.bind(MOD .. " + R",      hl.dsp.exec_cmd(programs.menu))
hl.bind(MOD .. " + F",      hl.dsp.exec_cmd(programs.browser))
hl.bind(MOD .. " + D",      hl.dsp.exec_cmd(programs.discord))
hl.bind(MOD .. " + M",      hl.dsp.exec_cmd(programs.suspend))

-- grim + slurp region screenshot.
hl.bind("Print", hl.dsp.exec_cmd(programs.screenshot))

---------------------
-- Window handling --
---------------------

-- Q rather than W, to match the browser's close-tab reflex.
hl.bind(MOD .. " + Q", hl.dsp.window.close())
hl.bind(MOD .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(MOD .. " + W", hl.dsp.window.fullscreen())

-- Cycle the two keyboard layouts declared in conf/input.lua.
hl.bind(MOD .. " + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Drag to move / resize with the mouse.
hl.bind(MOD .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(MOD .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--
-- Directional bindings.
--
-- Every direction supports both the vim keys and the arrow keys, across three
-- actions. Spelling that out by hand meant 24 near-identical lines that had to
-- be kept in sync; the table below is the single source of truth.
--
--   MOD          + <dir>  move focus
--   MOD + ALT    + <dir>  move the window
--   MOD + SHIFT  + <dir>  resize the window by RESIZE_STEP px
--
local RESIZE_STEP = 50

local DIRECTIONS = {
    { keys = { "H", "left"  }, dir = "left",  dx = -1, dy =  0 },
    { keys = { "L", "right" }, dir = "right", dx =  1, dy =  0 },
    { keys = { "K", "up"    }, dir = "up",    dx =  0, dy = -1 },
    { keys = { "J", "down"  }, dir = "down",  dx =  0, dy =  1 },
}

for _, d in ipairs(DIRECTIONS) do
    for _, key in ipairs(d.keys) do
        hl.bind(MOD .. " + " .. key, hl.dsp.focus({ direction = d.dir }))
        hl.bind(MOD .. " + ALT + " .. key, hl.dsp.window.move({ direction = d.dir }))
        hl.bind(MOD .. " + SHIFT + " .. key, hl.dsp.window.resize({
            x = d.dx * RESIZE_STEP,
            y = d.dy * RESIZE_STEP,
            -- `relative` keeps the old `resizeactive` behaviour: the numbers are
            -- a delta, not a target size.
            relative = true,
        }))
    end
end

----------------
-- Workspaces --
----------------

--   MOD       + <n>  switch to workspace n
--   MOD + ALT + <n>  send the focused window to workspace n
for ws = 1, 10 do
    local key = ws % 10 -- workspace 10 sits on the "0" key

    hl.bind(MOD .. " + " .. key,         hl.dsp.focus({ workspace = ws }))
    hl.bind(MOD .. " + ALT + " .. key,   hl.dsp.window.move({ workspace = ws }))
end

--------------------
-- Hardware keys  --
--------------------

-- `locked` lets these work while the screen is locked; `repeating` lets them
-- fire while held.
local HW = { locked = true, repeating = true }

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), HW)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      HW)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     HW)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                          HW)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                          HW)

-- Closing the lid suspends. hypridle's before_sleep_cmd locks the session first,
-- so this does not need to lock here as well.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(programs.suspend), { locked = true })

end
