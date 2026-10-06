--
-- Monitors and workspace placement.
--
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--

-- Catch-all fallback: any output not named below gets sane auto-detected
-- settings. This is what keeps a random projector or a new dock working.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- External display, placed above the laptop panel.
--
-- Alternative modes for the displays this machine actually meets, kept here so
-- switching is a one-line edit instead of a rediscovery exercise:
--   4K TV:            mode = "3840x2160@30"
--   Nexigo projector: mode = "1920x1080@60", scale = "auto"
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@100",
    position = "auto-up",
    scale    = 1,
})

-- XWayland apps have no fractional-scaling protocol, so they render blurry on a
-- scaled output. Forcing scale 1 makes them crisp (Hyprland then upscales).
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

--
-- Workspace pinning: 1-5 live on the laptop panel, 6-10 on HDMI.
-- When HDMI is unplugged, Hyprland moves 6-10 back to eDP-1 automatically.
--
-- The old config spelled all ten of these out by hand; the loop keeps the
-- split in exactly one place.
--
local LAPTOP, EXTERNAL = "eDP-1", "HDMI-A-1"

for ws = 1, 10 do
    local onLaptop = ws <= 5
    hl.workspace_rule({
        workspace = tostring(ws),
        monitor   = onLaptop and LAPTOP or EXTERNAL,
        -- First workspace of each monitor is the one it opens on.
        default   = (ws == 1 or ws == 6) or nil,
    })
end
