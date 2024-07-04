---@type WezTerm
local wezterm = require("wezterm")
local utils = require("utils")

local config = wezterm.config_builder()
config:set_strict_mode(true)

-- tabbar
utils.mergeTable(config, require("tabbar"))
-- config.hide_tab_bar_if_only_one_tab = true

-- theme
config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font("JetBrains Mono")
-- disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
-- config.window_background_opacity = 0.785
-- config.text_background_opacity = 1.
config.pane_select_font_size = 50
config.inactive_pane_hsb = {
	-- hue = 1.05,
	-- saturation = 0.6,
	-- brightness = 1.2,
}
config.window_padding = {
	left = 5,
	right = 5,
	top = 0,
	bottom = 3,
}
config.colors = {
	tab_bar = {
		-- "#cba6f7",
		-- background = "rgba(20,0,50,0.35)"
	},
}

-- update plugins
-- wezterm.plugin.update_all()

-- wezterm.plugin.require("https://github.com/SecretPocketCat/wezterm-bar").apply_to_config(config, {
-- 	position = "bottom",
-- 	max_width = 50,
-- 	dividers = "slant_right", -- or "slant_left", "arrows", "rounded", false
-- 	indicator = {
-- 		leader = {
-- 			enabled = false,
-- 			off = " ",
-- 			on = " ",
-- 		},
-- 		mode = {
-- 			enabled = true,
-- 			names = {
-- 				resize_mode = "RESIZE",
-- 				copy_mode = "VISUAL",
-- 				search_mode = "SEARCH",
-- 			},
-- 		},
-- 	},
-- 	tabs = {
-- 		numerals = "arabic", -- or "roman"
-- 		pane_count = false, -- or "subscript", false
-- 		brackets = {
-- 			active = { "", "" },
-- 			inactive = { "", "" },
-- 		},
-- 	},
-- })

return config
