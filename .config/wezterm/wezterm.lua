local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()
config:set_strict_mode(true)

-- todo:
-- unicode input
-- weird tab bar color
-- weird tab bar transparency (the slanted bgs are half-transparent)
-- rest of workspaces
-- get rid of the resize warning
-- float the error dialog window (same class as parent?)
-- repo selection sort based on frecency

local function trim(s, trimmed)
  local patt = string.format("^%s*(.-)%s*$", trimmed, trimmed)
  -- wezterm.log_info(patt)
  return s:match(patt)
end

local function execute_command(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  return result
end

local function active_win_class()
  local cmd = "hyprctl activewindow -j | jq '.class'"
  return execute_command(cmd):match("wez_([^\"]+)")
end

local function split(str, sep)
  local t = {}
  if not str then
    return t
  end

  for str in string.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end

  return t
end

local function get_repo_select_options(workspace, add_cancel)
  local env_key = 'WORKSPACE_' .. workspace
  local paths = os.getenv(env_key)
  if not paths then
    wezterm.log_warn("No paths for workspace " .. workspace .. " found in ENV: " .. env_key)
  end

  local repos = {};
  local paths = split(paths, ";");

  for _, pair in pairs(paths) do
    local i, _ = pair:find(":", 0, true)
    table.insert(repos, {
      label = pair:sub(0, i - 1),
      id = pair:sub(i + 1),
    })
  end

  if add_cancel then
    table.insert(repos, {
      label = "Cancel"
    })
  end

  return repos
end

local function open_repo_layout_tab(window, path, name, replace_tab)
  local tab_to_close = window:active_tab();

  local tab, build_pane, _ = window:mux_window():spawn_tab {
    cwd = path,
  }
  tab:set_title(name)
  local editor_pane = build_pane:split {
    direction = 'Top',
    size = 0.75,
    cwd = path,
  }
  build_pane:split {
    direction = 'Right',
    size = 0.4,
    cwd = path,
  }

  if replace_tab then
    tab_to_close:activate();
    window:perform_action(act.CloseCurrentTab { confirm = false }, tab_to_close:active_pane())
  end

  editor_pane:activate()
  editor_pane:send_text('hx . \n')
end

-- -- -- KEYBINDINGS -- -- --

local char_alphabet = 'tsrneiaoplfuwyzkjbvm'

local function repo_select(window, pane, replace_tab, strict_cancel)
  local workspace = active_win_class()
  if not workspace then
    wezterm.log_warn("No current workspace")
  end

  local repo_options = get_repo_select_options(workspace, strict_cancel)
  local title = workspace .. ' repo';
  if replace_tab then
    title = title .. " replace tab"
  end

  window:set_right_status(workspace)

  window:perform_action(
    act.InputSelector {
      action = wezterm.action_callback(
        function(_, _, path, name)
          print(name);
          print(path)
          if path and name then
            open_repo_layout_tab(window, path, name, replace_tab);
          elseif strict_cancel and not name and not path then
            repo_select(window, pane, replace_tab, strict_cancel)
          else
            wezterm.log_info 'Cancelled repo selection'
          end
        end
      ),
      title = title,
      choices = repo_options,
      fuzzy = true,
      fuzzy_description = title .. ":",
    },
    pane
  )
end

config.keys = {
  {
    key = 'w',
    mods = 'ALT',
    action = wezterm.action_callback(repo_select),
  },
  {
    key = 'w',
    mods = 'SHIFT|ALT',
    action = wezterm.action_callback(function(win, pane)
      repo_select(win, pane, true)
    end),
  },
  {
    key = 's',
    mods = 'ALT',
    action = act.PaneSelect {
      alphabet = char_alphabet,
    },
  },
}

-- -- -- STYLE -- -- --
config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font 'JetBrains Mono'
-- disable ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.window_background_opacity = 0.8
-- config.text_background_opacity = 1.
config.pane_select_font_size = 65
config.inactive_pane_hsb = {
  -- hue = 1.05,
  saturation = 0.6,
  brightness = 0.8,
}

-- -- -- INPUT -- -- --
config.use_ime = false
config.use_dead_keys = false
-- config.allow_win32_input_mode = true


-- -- -- EVENTS -- -- --

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window({})
  repo_select(window:gui_window(), pane, true, true)
end)

-- wezterm.on('update-right-status', function(window, pane)
--   window:set_right_status(window:active_workspace())
-- end)

-- -- -- TAB BAR -- -- --

-- config.hide_tab_bar_if_only_one_tab = true
-- config.window_padding = {
--     left = 2,
--     right = 2,
--     top = 0,
--     bottom = 0,
-- }

-- update plugins
-- wezterm.plugin.update_all()

wezterm.plugin.require("https://github.com/SecretPocketCat/wezterm-bar").apply_to_config(config, {
  position = "bottom",
  max_width = 30,
  dividers = "slant_right", -- or "slant_left", "arrows", "rounded", false
  indicator = {
    leader = {
      enabled = false,
      off = " ",
      on = " ",
    },
    mode = {
      enabled = true,
      names = {
        resize_mode = "RESIZE",
        copy_mode = "VISUAL",
        search_mode = "SEARCH",
      },
    },
  },
  tabs = {
    numerals = "arabic", -- or "roman"
    pane_count = false,  -- or "subscript", false
    brackets = {
      active = { "<", ">" },
      inactive = { "/", "/" },
    },
  },
})

return config
