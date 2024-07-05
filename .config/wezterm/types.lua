---@meta

---@alias NestedTaskProjects { [string]: string }

---@class ProjectWorkspace
---@field root string Root path
---@field root_task_project string Task pane project filter
---@field nested_task_projects NestedTaskProjects Task pane filter for nested projects
---@field extra_projects ExtraProject[] Additional projects outside the root or nested within other projects

---@class ExtraProject
---@field root string Root path
---@field task_project string? Task pane project filter

---@class ProjectOption
---@field id string Project path relative to home
---@field label string

---@class WorkspaceCacheEntry
---@field focusable table<FocusablePane, number>

---@alias FocusablePane "editor" | "term" | "git" | "filepicker" | "task" | "k9s"| "cheatsheet"
