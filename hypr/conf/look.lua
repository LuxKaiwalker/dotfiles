--
-- Look and feel: borders, gaps, decoration, animations, layout.
--
-- See https://wiki.hypr.land/Configuring/Basics/Variables/
--

-- Palette, named once so the border gradient and any future theming agree.
local GREEN_LIGHT = "rgba(81b29aee)"
local GREEN_DARK  = "rgba(3d5a40ee)"
local BORDER_IDLE = "rgba(0f1210aa)"

hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 2,

        col = {
            -- Gradients are a table in Lua rather than the old
            -- "rgba(..) rgba(..) 45deg" string.
            active_border   = { colors = { GREEN_LIGHT, GREEN_DARK }, angle = 45 },
            inactive_border = BORDER_IDLE,
        },

        layout = "dwindle",
    },

    decoration = {
        rounding = 0,

        -- Both opaque: blur below is for layer surfaces (waybar, wofi, mako),
        -- not for making windows see-through.
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 4,
            color        = "rgba(00000099)",
        },

        blur = {
            enabled  = true,
            size     = 5,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },

    dwindle = {
        -- Keep a split's orientation when its windows change, instead of
        -- re-deciding from the container's aspect ratio.
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,    -- no Hyprland mascot wallpaper
        disable_hyprland_logo   = true, -- no logo on an empty workspace
    },

    animations = {
        enabled = true,
    },
})

----------------
-- Animations --
----------------

-- Curves are declared separately from the animations that use them.
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })

-- `speed` is in deciseconds, as before. Only these three leaves are overridden;
-- everything else inherits Hyprland's defaults.
hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "default", style = "fade" })
