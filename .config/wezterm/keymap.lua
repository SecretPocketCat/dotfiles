local project = require("project")
local utils = require("utils")
---@type WezTerm
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local module = {}
local config = wezterm.config_builder()
config:set_strict_mode(true)

local char_alphabet = "tsrneiaoplfuwyzkjbvm"

config.disable_default_key_bindings = true
local main_mod = "ALT"
local main_mod_shifted = "SHIFT|" .. main_mod

config.keys = {
	{
		key = "p",
		mods = main_mod,
		action = act.ActivateCommandPalette,
	},
	{
		key = "w",
		mods = main_mod,
		action = wezterm.action_callback(project.workspace_select),
	},
	{
		key = "s",
		mods = main_mod,
		action = act.PaneSelect({
			alphabet = char_alphabet,
		}),
	},
	{
		key = "u",
		mods = main_mod,
		action = act.ScrollByPage(0.8),
	},
	{
		key = "y",
		mods = main_mod,
		action = act.ScrollByPage(-0.8),
	},
	-- {
	-- 	key = "e",
	-- 	mods = main_mod,
	-- 	action = act.ScrollByLine(1),
	-- },
	-- {
	-- 	key = "i",
	-- 	mods = main_mod,
	-- 	action = act.ScrollByLine(-1),
	-- },
	{
		key = "b",
		mods = main_mod,
		action = act.ScrollToBottom,
	},
	{
		key = "l",
		mods = main_mod,
		action = act.ScrollToTop,
	},
	{
		key = "n",
		mods = main_mod,
		action = act.ActivateTabRelative(-1),
	},
	-- {
	-- 	key = "o",
	-- 	mods = main_mod,
	-- 	action = act.ActivateTabRelative(1),
	-- },
	-- {
	-- 	key = "t",
	-- 	mods = main_mod,
	-- 	action = act.ShowLauncherArgs({ flags = "FUZZY|TABS" }),
	-- },
	-- tedo: replace by custom menu that has less noise and does not allow creating a new workspace
	{
		key = "a",
		mods = main_mod,
		action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
	-- {
	-- 	key = "x",
	-- 	mods = main_mod,
	-- 	action = act.ShowDebugOverlay,
	-- },
}

-- todo: this breaks on wez config save/reload
for focusable, key in pairs(project.keys) do
	table.insert(config.keys, {
		key = key,
		mods = main_mod,
		action = wezterm.action_callback(function()
			project.focus_ws_tab(focusable)
		end),
	})
end

-- todo: panes
-- pane size="65%" focus=true name="editor" {{
-- 	command "hx"
-- 	args "."
-- }}
-- pane stacked=true {{
-- 	pane name="cheatsheet" {{
-- 		command "glow"
-- 		args "/home/spc/.config/helix/cheatsheet.md"
-- 	}}
-- 	pane name="tasks" {{
-- 	 	command "task"
-- 	 	args "ls" "limit:20" "project:{}"
-- 	}}
-- 	pane name="tests" {{
-- 	 	command "bacon"
-- 	 	args "test" "-s"
-- 	}}
-- 	pane name="clippy" {{
-- 	 	command "bacon"
-- 	 	args "clippy" "-s"
-- 	}}
-- 	pane name="log" {{
-- 		command "tail"
-- 		args "/tmp/zellij-1000/zellij-log/zellij.log" "-F"
-- 	}}
-- }}

-- todo: keybinds
-- pub(crate) enum MessageKeybind {
--     OpenProject,
--     DashProject,
--     DashStatus,
--     DashTerminal,
--     FilePicker,
--     FocusEditorPane,
--     HxBufferJumplist,
--     HxOpenFile,
--     Git,
--     Terminal,
--     NewTerminal,
--     K9s,
-- }

config.enable_kitty_keyboard = true

return config
