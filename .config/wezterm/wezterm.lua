local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local project = require("project")
local utils = require("utils")

local config = wezterm.config_builder()
config:set_strict_mode(true)
utils.mergeTable(config, require("theme"))
utils.mergeTable(config, require("keymap"))

-- todo:
-- unicode input
-- rest of workspaces
-- get rid of the resize warning
-- float the error dialog window (same class as parent?)
-- repo selection sort based on frecency

-- EVENTS --
wezterm.on("gui-startup", function(cmd)
	local _, pane, window = mux.spawn_window({})
	-- todo: only when an arg is provided?
	-- repo_select(window:gui_window(), pane, true, true)
end)

return config
