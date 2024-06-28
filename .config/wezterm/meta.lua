---@meta

---@alias NestedTaskProjects { [string]: string }

---@class Project
---@field root string Root path
---@field root_task_project string Task pane project filter
---@field nested_task_projects NestedTaskProjects Task pane filter for nested projects
---@field extra_projects ExtraProject[] Additional projects outside the root or nested within other projects

---@class ExtraProject
---@field root string Root path
---@field task_project string? Task pane project filter

---@class ProjectOption
---@field path string
---@field label string
