local wezterm = require("wezterm")

local module = {}

function module.execute_command(command)
	local handle = io.popen(command)
	if not handle then
		error("Failed to create a process handle")
	end

	local result = handle:read("*a")
	handle:close()
	return result
end

function module.get_gui_pid()
	local pid = wezterm.procinfo.pid()
	local pinfo = wezterm.procinfo.get_info_for_pid(pid)

	while pinfo.name ~= "wezterm-gui" do
		pinfo = wezterm.procinfo.get_info_for_pid(pinfo.ppid)
	end

	return pinfo.pid
end

return module
