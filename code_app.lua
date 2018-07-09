
local ui = require'ui'
local glue = require'glue'

local tablist = ui.tablist:subclass'ce_tablist'

tablist.tab_slant_left = 85
tablist.tab_slant_right = 70
tablist.tab_spacing = -5

local tab = ui.tab:subclass'ce_tab'

tab.focusable = false
tab.title_padding_left = 5

ui:style('ce_tab :selected', {
	background_color = '#000',
})

local editbox = ui.editbox:subclass'ce_editbox'

editbox.multiline = true
editbox.ctrl_tab_exits = false
editbox.border_width = 0
editbox.editor = {
	line_numbers = true,
}

ui:style('ce_editbox, ce_editbox :focused', {
	shadow_blur = 0,
	background_color = false,
})

local frame = 'none'

local win = ui:window{
	x = 'center-active',
	y = 'center-active',
	w = 900,
	h = 600,
	min_cw = 300,
	min_ch = 200,
	--maximized = true,
	frame = frame,
	view = {
		border_width = 1,
		border_color = '#111',
		padding = frame == 'none' and 12 or 0,
		padding_top = frame ~= 'none' and 2 or nil,
	},
}

tab.closeable = true --show close button and receive 'closing' event

local tabs = tablist(win)

win.move_layer = tabs

tabs.max_click_chain = 2
function tabs:doubleclick()
	if win.ismaximized then
		win:restore()
	else
		win:maximize()
	end
end

function tabs:add_tab(file)

	local editbox = editbox(self.ui, {
		text = assert(glue.readfile(file)),
		visible = false,
		tab = tab,
	})

	local tab = self:tab{
		class = tab,
		title = file,
		editbox = editbox,
		selected = true,
	}

	return tab
end

function tab:tab_selected()
	if not self.editbox.ui then return end
	self.editbox.visible = true
	self.editbox:focus()
end

function tab:tab_unselected()
	self.editbox.visible = false
end

function tabs:after_sync()
	tabs.w = win.view.cw
	tabs.h = win.view.ch
	for i,tab in ipairs(self.tabs) do
		local e = tab.editbox
		e.parent = tab
		e.w = tab.w - 2
		e.h = tab.h - 2
	end
end

local xbutton = ui:button{
	font_family = 'Ionicons',
	text = '\xEF\x8B\x80',
	text_size = 12,
	parent = win,
	w = 40,
	h = 11,
	border_width_top = 0,
	corner_radius_bottom_left = 4,
	corner_radius_bottom_right = 4,
	background_color = '#222',
	border_color = '#444',
	text_color = '#999',
	cancel = true,
	visible = win.frame == 'none',
}

local t1 = tabs:add_tab('code_app.lua')
local t2 = tabs:add_tab('codedit.lua')
local t3 = tabs:add_tab('ui.lua')

function sync()
	tabs:sync(0)
	xbutton.x = win.view.cw - 40
	xbutton.y = -win.view.padding_top + 1
end

function win:client_rect_changed(cx, cy, cw, ch)
	sync()
end

sync()

ui:run()

