
local ui = require'ui'
local glue = require'glue'

ui:register_font_file('Code Icons', nil, nil, 'media/code/code_icons.ttf')

local tablist = ui.tablist:subclass'ce_tablist'

tablist.tab_slant_left = 85
tablist.tab_slant_right = 70
tablist.tab_spacing = -5
tablist.tabs_padding_right = 150

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

local split_button = ui:button{
	font_family = 'Code Icons',
	text = '\xEE\xA4\x80',
	text_size = 16,
	parent = win,
	w = 20,
	h = 20,
	profile = 'text',
	focusable = false,
}

local merge_button = ui:button{
	font_family = 'Code Icons',
	text = '\xEE\xA4\x81',
	text_size = 16,
	parent = win,
	w = 20,
	h = 20,
	profile = 'text',
	focusable = false,
}

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
	closeable = false,
	title_padding_left = 5,
}

function sync()
	tabs:sync(0)
	xbutton.x = win.view.cw - 40
	xbutton.y = -win.view.padding_top + 1

	split_button.x = win.view.cw - 100
	split_button.y = -win.view.padding_top + 10

	merge_button.x = win.view.cw - 124
	merge_button.y = -win.view.padding_top + 10
end

function win:client_rect_changed(cx, cy, cw, ch)
	sync()
end

sync()

ui:run()

