--
-- Window rules.
--
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- Every rule is named. The name is what `hyprctl` reports and what a rule
-- handle is addressed by, so it is worth spending a word on.
--

-- Apps that maximize themselves on launch are a nuisance under a tiling layout.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- XWayland drag-and-drop spawns a short-lived, untitled, floating surface. If
-- it takes focus the drag is dropped, so deny it focus.
hl.window_rule({
    name  = "no-focus-xwayland-floating",
    match = {
        class    = "^$",
        title    = "^$",
        xwayland = true,
        float    = true,
    },

    no_focus = true,
})

-- Modal dialogs (file pickers, confirmation prompts) belong in a centred
-- floating window rather than tiled into the layout.
hl.window_rule({
    name  = "float-modal-popups",
    match = { modal = true },

    float  = true,
    center = true,
})
