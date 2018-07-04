
local ui = require'ui'
local glue = require'glue'

local tablist = ui.tablist:subclass'ce_tablist'

tablist.main_tablist = false

local tab = ui.tab:subclass'ce_tab'

--tab.focusable = false

local editbox = ui.editbox:subclass'ce_editbox'

editbox.multiline = true
editbox.capture_tab = true
editbox.border_width = 0
editbox.editor = {
	line_numbers = true,
}

ui:style('ce_editbox :focused', {
	shadow_blur = 0,
	background_color = false,
})

local win = ui:window{
	w = 800,
	h = 500,
	maximized = true,
}

local tabs = tablist(win, {
	w = win.cw,
})

function tabs:add_tab(file)

	local editbox = editbox(win, {
		text = assert(glue.readfile(file)),
		visible = false,
	})

	local tab = self:tab{
		class = tab,
		text = file,
		editbox = editbox,
	}

	return tab
end

function tab:tab_selected()
	self.editbox.visible = true
	self.editbox:focus()
end

function tab:tab_unselected()
	self.editbox.visible = false
end

function tabs:after_sync()
	for i,tab in ipairs(self.tabs) do
		local e = tab.editbox
		e.w = win.cw
		e.h = win.ch - self.h
		e.y = win.ch - e.h
	end
end

function tabs:before_draw()
	self:sync()
end


local t1 = tabs:add_tab('code_app.lua')
local t2 = tabs:add_tab('codedit.lua')

ui:run()

