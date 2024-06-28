local utils = require("utils")
local process = require("process")
local debug = require("debug")
local wezterm = require("wezterm")
local act = wezterm.action

local module = {
	cancel_id = "cancel",
}

---@param root string
---@param root_task_project string
---@param nested_task_projects NestedTaskProjects?
---@param ... ExtraProject
local function workspace(root, root_task_project, nested_task_projects, ...)
	---@type Project
	return {
		root = root,
		root_task_project = root_task_project,
		nested_task_projects = nested_task_projects or {},
		extra_projects = ...,
	}
end

---@type Project
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

---@type Project[]
module.workspaces = {
	module.default_project,
	workspace("/work", "work", {
		bace = "bace",
	}),
	workspace("/gamedev", "gd"),
}

---@type ProjectOption
module.cancel_option = {
	path = "__cancel__",
	label = "󰘌 Cancel",
}

---@param workspace_root string
function module.get_repo_select_options(workspace_root)
	local cache_key = "ws_" .. workspace_root
	---@type ProjectOption[] | nil
	local options = wezterm.GLOBAL[cache_key]

	if not options then
		-- https://stackoverflow.com/a/78010951
		local repo_paths = wezterm.split_by_newlines(
			process.execute_command("find " .. workspace_root .. " -type d -exec test -d '{}/.git' \\; -prune -print")
		)

		---@type ProjectOption[]
		local repos = {}
		for _, path in ipairs(repo_paths) do
			-- parts of the regex are repeated, because {1,2} does not seem to work in lua
			local name = path:match("[/\\][^/\\]+[/\\][^/\\]+$")
			---@type ProjectOption
			local option = {
				label = name,
				path = path,
			}
			table.insert(repos, option)
		end

		-- local extra = extra_repos[workspace];
		-- if extra then
		--   for _, option in pairs(extra) do
		--     table.insert(repos, option)
		--   end
		-- end

		table.insert(repos, module.cancel_option)

		options = repos
		wezterm.GLOBAL[cache_key] = repos
	end

	return options
end

function module.repo_select(window, pane, replace_tab, strict_cancel)
	local ws_root = module.pane_project_root(pane)
	local project_options = module.get_repo_select_options(ws_root)
	-- local title = "todo: last bits of path" .. ' repo';
	local title = " project: " .. ws_root
	if replace_tab then
		title = title .. " REPLACE"
	end

	if strict_cancel then
		title = title .. " (STRICT CANCEL)"
	end

	window:set_right_status(ws_root)

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(_, _, path, name)
				if path and name and path ~= module.cancel_option.path then
					module.open_repo_layout_tab(window, path, name, replace_tab)
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

-- pub fn fzf_pane_cmd<'a>(
--     options: impl Iterator<Item = &'a str>,
--     message_type: impl Into<&'a str>,
--     message_client_id: Uuid,
--     use_index: bool,
-- ) -> CommandToRun {
--     let opts = options.into_iter().join("\n");

--     let fzf_layout_args = "--layout reverse";
--     let fzf_cmd = if use_index {
--         format!("command cat -n | fzf {fzf_layout_args} --with-nth 2.. | awk '{{print $1}}'")
--     } else {
--         format!("fzf {fzf_layout_args} ")
--     };

--     let cmd = format!(
--         "printf '{opts}' | {fzf_cmd} | zellij pipe  --name {} --args '{MSG_CLIENT_ID_ARG}={message_client_id}'",
--         message_type.into());
--     CommandToRun {
--         path: "bash".into(),
--         args: vec!["-c".to_string(), cmd],
--         cwd: None,
--     }
-- }

local function open_repo_layout_tab(window, path, name, replace_tab)
	local tab_to_close = window:active_tab()
	local mwin = window:mux_window()
	local editor_pane

	for _, tab in pairs(mwin:tabs()) do
		if tab:get_title() == name then
			editor_pane = tab:active_pane()
			if tab_to_close:get_title() == name then
				tab_to_close = nil
			end
		end
	end

	if not editor_pane then
		local tab, build_pane, _ = mwin:spawn_tab({
			cwd = path,
		})
		tab:set_title(name)
		editor_pane = build_pane:split({
			direction = "Top",
			size = 0.75,
			cwd = path,
		})
		editor_pane:send_text("hx . \n")
		build_pane:split({
			direction = "Right",
			size = 0.4,
			cwd = path,
		})
	end

	if replace_tab and tab_to_close then
		tab_to_close:activate()
		window:perform_action(act.CloseCurrentTab({ confirm = false }), tab_to_close:active_pane())
	end

	editor_pane:activate()
end

---@return string
function module.pane_project_root(pane)
	---@type string
	local cwd = pane:get_current_working_dir().file_path
	if cwd and cwd ~= wezterm.home_dir then
		for _, ws in ipairs(module.workspaces) do
			if cwd:match(ws.root) then
				return wezterm.home_dir .. ws.root
			end
		end
	end

	return wezterm.home_dir .. module.default_project.root
end

return module
