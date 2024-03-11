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
-- lower min size of the splits
-- get rid of the resize warning
-- float the error dialog window (same class as parent?)
-- workspace dropdown menus

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

local function get_workspace_select_options(workspace)
  local env_key = 'WORKSPACE_' .. workspace
  local paths = os.getenv(env_key)
  if not paths then
    wezterm.log_warn("No paths for workspace " .. workspace .. " found in ENV: " .. env_key)
  end

  local workspaces = {};
  local paths = split(paths, ";");

  for _, pair in pairs(paths) do
    local i, _ = pair:find(":", 0, true)
    table.insert(workspaces, {
      label = pair:sub(0, i - 1),
      id = pair:sub(i + 1),
    })
  end

  table.insert(workspaces, {
    label = "Cancel"
  })

  return workspaces
end

local function open_workspace(name, path)
  local tab, build_pane, window = mux.spawn_window {
    workspace = name,
    cwd = path,
  }
  local editor_pane = build_pane:split {
    direction = 'Top',
    size = 0.75,
    cwd = path,
  }
  local tool_pane = build_pane:split {
    direction = 'Right',
    size = 0.4,
    cwd = path,
  }

  editor_pane:activate()
  editor_pane:send_text('hx . \n')
end

-- -- -- KEYBINDINGS -- -- --

local char_alphabet = 'tsrneiaoplfuwyzkjbvm'

local function workspace_select(window, pane)
  local workspace = active_win_class()
  if not workspace then
    wezterm.log_warn("No current workspace")
  end

  local workspaces = get_workspace_select_options(workspace)
  local title = workspace .. ' Workspace';

  window:perform_action(
    act.InputSelector {
      action = wezterm.action_callback(
        function(inner_window, inner_pane, path, name)
          if not path and name then
            wezterm.log_info 'Cancelled workspace selection'
          elseif not path and not name then
            workspace_select(window, pane)
          else
            mux.set_active_workspace(name)
            -- inner_window:perform_action(
            --   function()

            --   end,
            --   -- act.SwitchToWorkspace {
            --   --   name = name,
            --   --   spawn = {
            --   --     label = name,
            --   --     cwd = path,
            --   --   },
            --   -- },
            --   inner_pane
            -- )
          end
        end
      ),
      title = title,
      choices = workspaces,
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
    -- action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
    action = wezterm.action_callback(workspace_select),
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
config.window_background_opacity = 0.9
config.text_background_opacity = 0.9
config.pane_select_font_size = 65
-- config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- config.window_padding = {
--     left = 2,
--     right = 2,
--     top = 0,
--     bottom = 0,
-- }


-- wezterm.plugin.require("https://github.com/nekowinston/wezterm-bar").apply_to_config(config, {
--     position = "top",
--     max_width = 40,
--     dividers = "slant_right", -- or "slant_left", "arrows", "rounded", false
--     indicator = {
--         leader = {
--             enabled = false,
--             off = " ",
--             on = " ",
--         },
--         mode = {
--             enabled = true,
--             names = {
--                 resize_mode = "RESIZE",
--                 copy_mode = "VISUAL",
--                 search_mode = "SEARCH",
--             },
--         },
--     },
--     tabs = {
--         numerals = "arabic",        -- or "roman"
--         pane_count = "superscript", -- or "subscript", false
--         brackets = {
--             active = { "[", "]" },
--             inactive = { "", ":" },
--         },
--     },
-- })

-- -- -- INPUT -- -- --
config.use_ime = false
config.use_dead_keys = false
-- config.allow_win32_input_mode = true


-- -- -- LAYOUT & WORKSPACES -- -- --
local function init_code_workspaces(workspace)
  for _, ws in pairs(get_workspace_select_options(workspace)) do
    print(ws)
    local tab, build_pane, window = mux.spawn_window {
      workspace = ws.label,
      cwd = ws.id,
    }
    local editor_pane = build_pane:split {
      direction = 'Top',
      size = 0.75,
      cwd = ws.id,
    }
    local tool_pane = build_pane:split {
      direction = 'Right',
      size = 0.4,
      cwd = ws.id,
    }

    editor_pane:activate()
    editor_pane:send_text('hx . \n')
  end
end

wezterm.on('gui-startup', function(cmd)
  init_code_workspaces("work")
  init_code_workspaces("gamedev")
  -- todo: rest
  -- init_code_workspaces("projects")

  local tab, pane, window = mux.spawn_window({})
  workspace_select(window:gui_window(), pane)
end)

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())
end)

return config
