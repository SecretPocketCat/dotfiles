return {
	entry = function()
		local h = cx.active.current.hovered
		if h and h.cha.is_dir then
			ya.manager_emit("enter", { hovered = true })
		else
			ya.manager_emit("open", { })
		end
	end,
}
