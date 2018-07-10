
local ui = require'ui'
local glue = require'glue'

ui:register_font_file('Code Icons', nil, nil, 'media/fonts/code_icons.ttf')

local tablist = ui.tablist:subclass'ce_tablist'

tablist.tab_slant_left = 85
tablist.tab_slant_right = 70
tablist.tab_spacing = -5
tablist.tabs_padding_right = 160

local tab = ui.tab:subclass'ce_tab'

tab.focusable = false
tab.title_padding_left = 5
tab.title_color = '#aaa'

ui:style('ce_tab :selected', {
	border_color = '#111',
	title_color = '#ccc',
})

ui:style('ce_tab :selected', {
	background_color = '#000',
})

local editbox = ui.editbox:subclass'ce_editbox'

editbox.multiline = true
editbox.padding_top = 0
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
	frame = frame,
	view = {
		border_width = 1,
		border_color = '#111',
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

function tabs:before_sync()
	tabs.w = win.view.cw
	tabs.h = win.view.ch
end

function tabs:after_sync()
	for i,tab in ipairs(self.tabs) do
		local e = tab.editbox
		if e then
			e.parent = tab
			e.w = tab.w - 2
			e.h = tab.h - 2
		end
	end
end

function tab:closed()
	if self.tablist:visible_tab_count() == 0 then
		local tab = self.tablist.tabs[1]
		tab.visible = true
		tab:select()
	end
end

local sysbutton = {
	font_family = 'Font Awesome',
	text_size = 7,
	parent = win,
	w = 30,
	h = 11,
	border_width_top = 0,
	corner_radius_bottom_left = 4,
	corner_radius_bottom_right = 4,
	background_color = '#222',
	border_color = '#444',
	text_color = '#999',
	visible = win.frame == 'none',
	focusable = false,
}

local close_button = ui:button(sysbutton, {
	font_family = 'Ionicons',
	text = '\xEF\x8B\x80',
	text_size = 12,
	w = 40,
	corner_radius_bottom_left = 0,
	cancel = true,
	pressed = function(self)
		if self.active_by_key and win.ismaximized then
			win:restore()
			return true
		end
	end,
})

local maximize_button = ui:button(sysbutton, {
	text = '\xEF\x8B\x90',
	corner_radius_bottom_left = 0,
	corner_radius_bottom_right = 0,
	pressed = function()
		if win.ismaximized then
			win:restore()
		else
			win:maximize()
		end
	end,
})

local minimize_button = ui:button(sysbutton, {
	text = '\xEF\x8B\x91',
	corner_radius_bottom_right = 0,
	pressed = function()
		win:minimize()
	end,
})

local toolbutton = {
	parent = win,
	font_family = 'Code Icons',
	text_size = 12,
	w = 20,
	h = 20,
	profile = 'text',
	focusable = false,
}

local menu_button = ui:button(toolbutton, {
	font_family = 'Ionicons',
	text = '\xEF\x8C\xAA',
	text_size = 16,
	tooltip = 'Menu | Shift+Esc',
})

local split_button = ui:button(toolbutton, {
	text = '\xEE\xA4\x81',
	tooltip = 'Split window horizontally | Ctrl+S',
})

local merge_button = ui:button(toolbutton, {
	text = '\xEE\xA4\x80',
	tooltip = 'Unsplit window | Ctrl+U',
})

local t1 = tabs:add_tab('code_app.lua')
local t2 = tabs:add_tab('codedit.lua')
local t3 = tabs:add_tab('ui.lua')

local empty_tab = tabs:tab{
	index = 1,
	title = 'Drag a tab here...',
	background_type = false,
	border_dash = 5,
	title_color = '#999',
	visible = false,
	title_padding_left = 5,
	draggable = false,
	focusable = false,
	closed = function()
		win:close()
	end,
}

function sync()

	if win.ismaximized then
		win.view.padding = 0
	else
		win.view.padding = win.frame == 'none' and 10 or 0
	end

	tabs:sync(0)

	local r = win.view.cw - 40
	local y = -win.view.padding_top + 1
	close_button.x = r
	close_button.y = y

	maximize_button.x = r - 30
	maximize_button.y = y

	minimize_button.x = r - 60
	minimize_button.y = y

	local dx = win.view.cw - (win.ismaximized and 120 or 0)
	local dy = -win.view.padding_top + 15 - (win.ismaximized and 12 or 0)

	local r = dx - 80
	local y = dy
	split_button.x = r
	split_button.y = y

	merge_button.x = r + split_button.w - 2
	merge_button.y = y

	local r = dx - 18
	local y = dy
	menu_button.x = r
	menu_button.y = y

	win:invalidate()
end

function win:client_rect_changed(cx, cy, cw, ch)
	sync()
end

sync()

ui:run()

