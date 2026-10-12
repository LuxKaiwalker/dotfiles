--
-- Status bar (waybar) visibility.
--
-- Waybar sits on the left screen edge, 30px wide, as an exclusive layer
-- surface (see waybar/config.jsonc), so tiled windows normally start 30px in
-- from the left border. SUPER+A hands those 30px back; SUPER+A again returns
-- the bar (SUPER+W stayed on fullscreen).
--
-- Hiding is waybar's own SIGUSR1 toggle rather than `pkill waybar`:
--
--   * it drops every bar into waybar's "invisible" mode, which releases the
--     exclusive zone — the compositor's reserved area goes to 0 and windows
--     reflow to the screen edge — and makes the surface input-transparent, so
--     no leftover 30px strip swallows clicks;
--   * waybar keeps running, so the bar comes straight back with its modules
--     and their state intact, instead of paying for a restart.
--
-- The exclusive zone is not the only thing between a window and the left
-- border, though: general:gaps_out adds its own. So hiding also pins the left
-- gap to 0 and showing restores the gaps the config asked for. With gaps_out
-- at 0 (conf/look.lua as of today) that half is a no-op, but it keeps the
-- promise "bar hidden means 0px to the left border" true if the gaps grow.
--

-- Namespace waybar's layer surfaces carry, as `hyprctl layers` reports it.
local WAYBAR_NAMESPACE = "waybar"

-- Hyprland backgrounds this itself, see the note in conf/autostart.lua.
local WAYBAR_CMD = "waybar"

-- The gaps as the config *file* asks for them, read while that file is being
-- parsed — so this is never a value some earlier toggle left behind, and it is
-- re-read on every `hyprctl reload`. conf/look.lua has to be required before
-- this module; the entry point is where that order is spelled out.
local CONFIGURED_GAPS = hl.get_config("general:gaps_out")

-- The same gaps with the left one dropped.
local FLUSH_LEFT_GAPS = {
    top    = CONFIGURED_GAPS.top,
    right  = CONFIGURED_GAPS.right,
    bottom = CONFIGURED_GAPS.bottom,
    left   = 0,
}

--
-- Where the bar currently stands: "visible", "hidden", or "gone" when waybar
-- is not running at all.
--
-- This asks the compositor instead of remembering the last toggle in a local,
-- so the binding still does the right thing after a `hyprctl reload` (which
-- re-runs this file but leaves the running waybar exactly as it was) or after
-- a SIGUSR1 sent from somewhere else.
--
local function barState()
    local state = "gone"

    for _, layer in ipairs(hl.get_layers()) do
        if layer.namespace == WAYBAR_NAMESPACE then
            -- A hidden bar keeps its surface, so the surface existing only
            -- proves waybar is alive. The monitor's reserved area is what says
            -- whether the bar is actually on screen — `left`, because that is
            -- the edge this bar is docked to.
            if layer.monitor and layer.monitor.reserved.left > 0 then
                return "visible"
            end

            state = "hidden"
        end
    end

    return state
end

local function setGaps(gaps)
    hl.config({ general = { gaps_out = gaps } })
end

return {
    --- Hide the bar when it is showing, show it when it is hidden.
    toggle = function()
        local state = barState()

        if state == "gone" then
            -- Nothing to toggle — waybar died, or never came up. Start it,
            -- and put the gaps back where a visible bar wants them.
            setGaps(CONFIGURED_GAPS)
            hl.exec_cmd(WAYBAR_CMD)
            return
        end

        -- Gaps first, signal second. Changing the gaps does not re-tile
        -- anything on its own, whereas waybar's exclusive zone appearing or
        -- disappearing does; setting them up front means that one
        -- recalculation already sees the new gaps, instead of leaving the
        -- layout one toggle behind.
        setGaps(state == "visible" and FLUSH_LEFT_GAPS or CONFIGURED_GAPS)

        -- One signal either way: waybar's own handler flips each of its bars
        -- between the visible and the invisible mode.
        hl.exec_cmd("pkill -SIGUSR1 -x " .. WAYBAR_CMD)
    end,
}
