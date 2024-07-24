---@type WezTerm
local wezterm = require("wezterm")
local mux = wezterm.mux

local module = {}

function module.mergeTable(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				module.mergeTable(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

function module.notify(text)
	module.execute_command("notify-send -t 100000 -u low " .. text)
end

function module.split(str, sep)
	local t = {}
	if not str then
		return t
	end

	for s in module.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(t, s)
	end

	return t
end

function module.trim_str(s, trimmed)
	local patt = string.format("^%s*(.-)%s*$", trimmed, trimmed)
	return s:match(patt)
end

function module.trim(s)
	return module.trim_str(s, " ")
end

--- Check whether text is nil or empty
---@param s string? Text
---@return boolean
function module.nil_or_empty(s)
	return s == nil or module.trim(s) == ""
end

---@generic T
---@param haystack T[]
---@param needle T
---@return boolean
function module.contains(haystack, needle)
	for _, val in ipairs(haystack) do
		if val == needle then
			return true
		end
	end

	return false
end

---@generic T
---@param haystack T[]
---@param predicate fun(value: T, i: number): boolean
---@return T | nil
function module.find(haystack, predicate)
	for i, value in pairs(haystack) do
		if predicate(value, i) then
			return value
		end
	end

	return nil
end

---@param command string
---@return string
function module.execute_command(command)
	local handle = io.popen(command)
	if not handle then
		error("Failed to create a process handle")
	end

	local result = handle:read("*a")
	handle:close()
	return result
end

---@return number
function module.get_gui_pid()
	local pid = wezterm.procinfo.pid()
	local pinfo = wezterm.procinfo.get_info_for_pid(pid)

	while pinfo.name ~= "wezterm-gui" do
		pinfo = wezterm.procinfo.get_info_for_pid(pinfo.ppid)
	end

	return pinfo.pid
end

---@generic T
---@param t { [T]: any }
---@return T[]
function module.sorted_keys(t)
	local keys = {}

	for k in pairs(t) do
		table.insert(keys, k)
	end

	table.sort(keys)
	return keys
end

---@param pane _.wezterm.Pane
function module.close_pane(pane)
	pane:activate()
	pane:window():gui_window():perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), pane)
end

---@param pane_id number
function module.close_pane_by_id(pane_id)
	local pane = mux.get_pane(pane_id)
	if pane then
		module.close_pane(pane)
	end
end

return module
