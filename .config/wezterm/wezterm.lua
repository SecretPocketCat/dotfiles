local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()
config:set_strict_mode(true)

-- todo:
-- get rid of the extra padding at the bottom
-- unicode input
-- rest of workspaces
-- get rid of the resize warning
-- float the error dialog window (same class as parent?)
-- repo selection sort based on frecency

local workspace_roots = {
  work = "~/work",
  gamedev = "~/gamedev",
  hobby = "~/projects",
}
local extra_repos = {
  hobby = {
    {
      id = wezterm.home_dir .. "/dotfiles",
      label = "dotfiles"
    }
  }
}

local cancel_id = "cancel";

local function execute_command(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  return result
end

local function notify(text)
  execute_command("notify-send -t 100000 -u low " .. text)
end

local function trim(s, trimmed)
  local patt = string.format("^%s*(.-)%s*$", trimmed, trimmed)
  -- wezterm.log_info(patt)
  return s:match(patt)
end

local function get_gui_pid()
  local pid = wezterm.procinfo.pid()
  local pinfo = wezterm.procinfo.get_info_for_pid(pid)

  while pinfo.name ~= "wezterm-gui" do
    pinfo = wezterm.procinfo.get_info_for_pid(pinfo.ppid)
  end

  return pinfo.pid
end

local function gui_class_workspace()
  local pid = get_gui_pid()
  local class = execute_command("hyprctl clients -j | jq '.[] | select(.pid == " .. pid .. ") | .class'")
  return class:match("wez_([^\"]+)")
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
  local options = wezterm.GLOBAL.workspace_repo_options

  if not options then
    local workspace_root = workspace_roots[workspace]
    local repo_paths = wezterm.split_by_newlines(execute_command("find " ..
      workspace_root .. " -name .git -exec dirname {} \\; -prune"))
    local repos = {}
    for _, path in pairs(repo_paths) do
      -- parts of the regex are repeated, 'cause {1,2} does not seem to work in lua
      local name = path:match("[^/\\]+[/\\][^/\\]+$")
      table.insert(repos, {
        -- name
        label = name,
        -- path
        id = path,
      })
    end

    local extra = extra_repos[workspace];
    if extra then
      for _, option in pairs(extra) do
        table.insert(repos, option)
      end
    end

    options = repos
    wezterm.GLOBAL.workspace_repo_options = repos
  end

  if add_cancel then
    options[#options + 1] = nil
    table.insert(options, {
      label = "Cancel",
      id = cancel_id,
    })
  end

  return options
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

local char_alphabet = 'tsrneiaoplfuwyzkjbvm'

local function repo_select(window, pane, replace_tab, strict_cancel)
  local workspace = gui_class_workspace()
  if not workspace then
    wezterm.log_warn("No current workspace")
  end

  local repo_options = get_repo_select_options(workspace, strict_cancel)
  local title = workspace .. ' repo';
  if replace_tab then
    title = title .. " replace tab"
  end

  if strict_cancel then
    title = title .. " (strict cancel)"
  end

  window:set_right_status(workspace)

  window:perform_action(
    act.InputSelector {
      action = wezterm.action_callback(
        function(_, _, path, name)
          if path and name and name ~= cancel_id then
            open_repo_layout_tab(window, path, name, replace_tab)
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

-- -- -- KEYBINDINGS -- -- --

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
    key = 'w',
    mods = main_mod,
    action = wezterm.action_callback(repo_select),
  },
  {
    key = 'w',
    mods = main_mod_shifted,
    action = wezterm.action_callback(function(win, pane)
      repo_select(win, pane, true)
    end),
  },
  {
    key = 's',
    mods = main_mod,
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
-- config.window_background_opacity = 0.985
-- config.text_background_opacity = 1.
config.pane_select_font_size = 65
config.inactive_pane_hsb = {
  -- hue = 1.05,
  saturation = 0.6,
  brightness = 0.8,
}

-- -- -- INPUT -- -- --
config.enable_kitty_keyboard = true
config.use_ime = false
config.use_dead_keys = false
-- config.allow_win32_input_mode = true


-- -- -- EVENTS -- -- --

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window({})
  repo_select(window:gui_window(), pane, true, true)
end)

-- -- -- TAB BAR -- -- --

-- config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
  left = 5,
  right = 5,
  top = 0,
  bottom = 3,
}

-- update plugins
-- wezterm.plugin.update_all()

wezterm.plugin.require("https://github.com/SecretPocketCat/wezterm-bar").apply_to_config(config, {
  position = "top",
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

config.colors = {
  tab_bar = {
    -- "#cba6f7"
    -- background = "rgba(20,0,50,0.35)"
  }
}

return config
