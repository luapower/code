
local ui = require'ui'

local tablist = ui.tablist:subclass'ce_tablist'

local win = ui:window{
	w = 800,
	h = 500,
	--maximized = true,
}

local tabs = tablist(win, {
	w = win.cw,
	h = 20,
	tabs = {
		{text = 'hey!'},
		{text = 'hey hei!'},
	}
})

function tabs:add_tab(file)

	local edit = ui:editbox{
		parent = win,
		multiline = true,
	}

end

ui:run()

