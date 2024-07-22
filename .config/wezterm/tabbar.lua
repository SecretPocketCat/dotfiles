---@type WezTerm
local wezterm = require("wezterm")
local mux = wezterm.mux
local utils = require("utils")

local config = wezterm.config_builder()
config:set_strict_mode(true)

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 50

-- slant right
local divider = utf8.char(0xe0bc)
-- arrow
-- local divider = utf8.char(0xe0b0)

wezterm.on("format-window-title", function(tab, tabs, _panes, conf, _hover, _max_width)
	return mux.get_active_workspace()
end)

wezterm.on("format-tab-title", function(tab, tabs, _panes, conf, _hover, _max_width)
	local colours = conf.resolved_palette.tab_bar

	local active_tab_index = 0
	for _, t in ipairs(tabs) do
		if t.is_active == true then
			active_tab_index = t.tab_index
		end
	end

	local inactive = {
		colours.inactive_tab.bg_color,
		colours.new_tab.bg_color,
	}

	local active_bg = colours.active_tab.bg_color
	local active_fg = colours.active_tab.fg_color
	local inactive_bg = inactive[(tab.tab_index % 2) + 1]
	local next_inactive_bg = inactive[((tab.tab_index + 1) % 2) + 1]
	local inactive_fg = colours.inactive_tab.fg_color
	local new_tab_bg = colours.new_tab.bg_color

	local s_bg, s_fg, e_bg, e_fg

	-- the last tab
	if tab.tab_index == #tabs - 1 then
		if tab.is_active then
			s_bg = active_bg
			s_fg = active_fg
			e_bg = colours.new_tab.bg_color
			e_fg = active_bg
		else
			s_bg = inactive_bg
			s_fg = inactive_fg
			e_bg = new_tab_bg
			e_fg = inactive_bg
		end
	elseif tab.tab_index == active_tab_index - 1 then
		s_bg = inactive_bg
		s_fg = inactive_fg
		e_bg = active_bg
		e_fg = inactive_bg
	elseif tab.is_active then
		s_bg = active_bg
		s_fg = active_fg
		e_bg = next_inactive_bg
		e_fg = active_bg
	else
		s_bg = inactive_bg
		s_fg = inactive_fg
		e_bg = next_inactive_bg
		e_fg = inactive_bg
	end

	local tabtitle = tab.tab_title
	if utils.nil_or_empty(tabtitle) then
		tabtitle = "[" .. tab.tab_index .. "]"
	end

	local width = conf.tab_max_width - 1
	if #tabtitle > conf.tab_max_width then
		tabtitle = wezterm.truncate_right(tabtitle, width) .. "…"
	end

	local title = string.format("  %s  ", tabtitle)

	return {
		{ Background = { Color = s_bg } },
		{ Foreground = { Color = s_fg } },
		{ Text = title },
		{ Background = { Color = e_bg } },
		{ Foreground = { Color = e_fg } },
		{ Text = divider },
	}
end)

wezterm.on("update-status", function(window, pane)
	local ws_names = wezterm.GLOBAL.workspace_names

	if ws_names then
		---@type _.wezterm.Palette
		local palette = window:effective_config().resolved_palette

		---@type _.wezterm.FormatItem[]
		local items = {}
		for _, ws in ipairs(mux.get_workspace_names()) do
			table.insert(items, {
				Background = {
					Color = mux.get_active_workspace() == ws and palette.ansi[2] or palette.ansi[1],
				},
			})
			table.insert(items, {
				-- Text = ws_names[ws],
				-- todo: cached name or similar
				Text = ws,
			})
		end
		window:set_right_status(wezterm.format(items))
	end
end)

return config
