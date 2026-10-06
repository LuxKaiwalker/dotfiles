--
-- Keyboard, pointer and touchpad.
--
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
--
hl.config({
    input = {
        -- Two layouts, toggled by SUPER+SPACE (see conf/binds.lua). The empty
        -- first variant means plain QWERTY; the second is Colemak on the same
        -- "us" layout.
        kb_layout  = "us,us",
        kb_variant = ",colemak",

        -- Caps Lock acts as an extra Super, which is what every binding in
        -- conf/binds.lua is built on.
        kb_options = "caps:super",

        follow_mouse = 1,

        sensitivity  = 0.25,
        accel_profile = "adaptive",

        touchpad = {
            natural_scroll = false,
        },
    },
})
