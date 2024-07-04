---@type WezTerm
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local utils = require("utils")

local module = {
	cancel_id = "cancel",
}

---@param root string
---@param root_task_project string
---@param nested_task_projects NestedTaskProjects?
---@param ... ExtraProject
local function workspace(root, root_task_project, nested_task_projects, ...)
	---@type ProjectWorkspace
	return {
		root = root,
		root_task_project = root_task_project,
		nested_task_projects = nested_task_projects or {},
		extra_projects = { ... },
	}
end

---@type ProjectWorkspace
module.default_project = workspace("/projects", "l", {
	zellij = "l.zellij",
	helix = "l.hx",
}, {
	root = "/dotfiles",
}, {
	root = "/dotfiles/.config/wezterm",
	task_project = "l.wez",
}, {
	root = "/projects/keebs/qmk/keyboards/klor/keymaps/secretpocketcat/",
})

---@type ProjectWorkspace[]
module.workspaces = {
	module.default_project,
	workspace("/work", "work", {
		bace = "bace",
	}),
	workspace("/gamedev", "gd"),
}

---@type ProjectOption
module.cancel_option = {
	id = "__cancel__",
	label = "󰘌 Cancel",
}

---@param project_ws ProjectWorkspace
function module.get_repo_select_options(project_ws)
	local cache_key = "ws_" .. project_ws.root
	---@type ProjectOption[] | nil
	local options = wezterm.GLOBAL[cache_key]

	if not options then
		-- https://stackoverflow.com/a/78010951
		local repo_paths = wezterm.split_by_newlines(
			utils.execute_command(
				"find " .. wezterm.home_dir .. project_ws.root .. " -type d -exec test -d '{}/.git' \\; -prune -print"
			)
		)

		---@type ProjectOption[]
		local repos = {}

		for _, path in ipairs(repo_paths) do
			-- parts of the regex are repeated, because {1,2} does not seem to work in lua
			local name = path:match("[/\\][^/\\]+[/\\][^/\\]+$"):gsub(project_ws.root, "")
			---@type ProjectOption
			local option = {
				label = name,
				id = path,
			}
			table.insert(repos, option)
		end

		for _, p in pairs(project_ws.extra_projects) do
			---@type ProjectOption
			local option = {
				label = p.root:gsub(project_ws.root, ""),
				id = wezterm.home_dir .. p.root,
			}

			table.insert(repos, option)
		end

		table.insert(repos, module.cancel_option)

		options = repos
		wezterm.GLOBAL[cache_key] = repos
	end

	return options
end

function module.repo_select(window, pane, replace_tab, strict_cancel)
	local project_ws = module.pane_project(pane)
	local project_options = module.get_repo_select_options(project_ws)
	local title = "  " .. project_ws.root
	if replace_tab then
		title = title .. " REPLACE"
	end

	if strict_cancel then
		title = title .. " (STRICT CANCEL)"
	end

	window:set_right_status(project_ws.root)

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(_, _, path, name)
				if path and name and path ~= module.cancel_option.id then
					module.open_project_workspace(window, path)
				elseif strict_cancel and not name and not path then
					module.repo_select(window, pane, replace_tab, strict_cancel)
				else
					wezterm.log_info("Cancelled repo selection")
				end
			end),
			title = title,
			choices = project_options,
			fuzzy = true,
			fuzzy_description = title .. ":",
		}),
		pane
	)
end

--- Open project workspace
---@param window _.wezterm.Window
---@param path string
function module.open_project_workspace(window, path)
	if window:active_workspace() == path then
		-- workspace already openede & focused - bail
		return
	end

	if not utils.contains(mux.get_workspace_names(), path) then
		local tab, editor_pane, win = mux.spawn_window({
			workspace = path,
			cwd = path,
			args = { "hx", "." },
		})
		tab:set_title("hx")

		-- status
		-- todo: actually base the cmd of this pane on the project type
		-- & possibly just skip it if it doesn't need one
		--  =>
		-- bacon for rust (cargo.toml)
		-- glow for md (possible split might be different than regular code)
		-- ??? for web (package.json)
		local status_pane = editor_pane:split({
			direction = "Right",
			size = 0.325,
			cwd = path,
		})
		status_pane:send_text("bacon clippy --summary \n")

		-- additional tabs
		local yazi_tab, yazi_pane = win:spawn_tab({
			cwd = path,
		})
		yazi_tab:set_title("yazi")
		yazi_pane:send_text("yazi . \n")

		local git_tab = win:spawn_tab({
			cwd = path,
			args = { "lazygit" },
		})
		git_tab:set_title("git")

		-- todo: use project filter from conf
		local task_tab, task_pane = win:spawn_tab({
			cwd = path,
		})
		task_tab:set_title("tasks")
		task_pane:send_text("task \n")

		local cheatsheet_tab, cheatsheet_pane = win:spawn_tab({
			cwd = path,
		})
		cheatsheet_tab:set_title("cheatsheet")
		cheatsheet_pane:send_text("glow ~/.config/helix/cheatsheet.md \n")

		-- focus editor pane
		editor_pane:activate()
	end

	mux.set_active_workspace(path)
end

---@return ProjectWorkspace
function module.pane_project(pane)
	---@type string
	local cwd = pane:get_current_working_dir().file_path
	if cwd and cwd ~= wezterm.home_dir then
		for _, ws in ipairs(module.workspaces) do
			if cwd:match(ws.root) then
				return ws
			end
		end
	end

	return module.default_project
end

return module
