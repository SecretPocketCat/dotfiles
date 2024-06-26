local project = require 'project'
local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()
config:set_strict_mode(true)

local char_alphabet = 'tsrneiaoplfuwyzkjbvm'

config.disable_default_key_bindings = true
local main_mod = 'ALT'
local main_mod_shifted = 'SHIFT|' .. main_mod

config.keys = {
  {
    key = 'p',
    mods = main_mod,
    action = act.ActivateCommandPalette,
  },
  {
    key = 'r',
    mods = main_mod,
    action = wezterm.action_callback(project.repo_select),
  },
  -- {
  --   key = 'r',
  --   mods = main_mod_shifted,
  --   action = wezterm.action_callback(function(win, pane)
  --     repo_select(win, pane, true)
  --   end),
  -- },
  {
    key = 's',
    mods = main_mod,
    action = act.PaneSelect {
      alphabet = char_alphabet,
    },
  },
  {
    key = 'u',
    mods = main_mod,
    action = act.ScrollByPage(0.8),
  },
  {
    key = 'y',
    mods = main_mod,
    action = act.ScrollByPage(-0.8),
  },
  {
    key = 'e',
    mods = main_mod,
    action = act.ScrollByLine(1),
  },
  {
    key = 'i',
    mods = main_mod,
    action = act.ScrollByLine(-1),
  },
  {
    key = 'b',
    mods = main_mod,
    action = act.ScrollToBottom,
  },
  {
    key = 'l',
    mods = main_mod,
    action = act.ScrollToTop,
  },
  {
    key = 'n',
    mods = main_mod,
    action = act.ActivateTabRelative(-1),
  },
  {
    key = 'o',
    mods = main_mod,
    action = act.ActivateTabRelative(1),
  },
    {
    key = 't',
    mods = main_mod,
    action = act.ShowLauncherArgs { flags = 'FUZZY|TABS' },
  },
}

config.enable_kitty_keyboard = true

return config
