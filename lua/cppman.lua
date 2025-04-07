local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local Popup = require("nui.popup")

local M = {}

local function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local stack = {}
local current_page = nil

local function reload(manwidth, word_to_search)
	vim.bo.ro = false
	vim.bo.ma = true

	vim.api.nvim_buf_set_lines(0, 0, -1, true, {})

	local cmd = string.format([[0r! cppman --force-columns %s '%s' ]], manwidth, word_to_search)
	vim.cmd(cmd) -- Set buffer with cppman contents
	vim.cmd("0") -- Go to top of document

	vim.bo.ro = true
	vim.bo.ma = false
	vim.bo.mod = false

	vim.bo.keywordprg = "cppman"
	vim.bo.buftype = "nofile"
	vim.bo.filetype = "cppman"
end

local function loadNewPage()
	if current_page ~= nil then
		table.insert(stack, current_page)
	end

	current_page = vim.fn.expand('<cWORD>')

	local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
	local manwidth = wininfo.width - 4;

	reload(manwidth, current_page)
end

local function backToPrevPage()
	if table.getn(stack) == 0 then
		return
	end

	current_page = table.remove(stack)

	local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
	local manwidth = wininfo.width - 4;

	reload(manwidth, current_page)
end

M.setup = function()

	vim.api.nvim_create_user_command('CPPMan', function(args)
		if args.args ~= nil then
			if string.len(args.args) > 1 then
				M.open_cppman_for(args.args)
			else
				M.input()
			end
		else
			M.input()
		end
	end, { nargs = "?" }
	)

end

M.input = function()
	local input = Input({
		position = "50%",
		size = {
			width = 20,
		},
		border = {
			style = "double",
			text = {
				top = "[Search cppman]",
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		prompt = "> ",
		default_value = "",
		on_close = function()
		end,
		on_submit = function(value)
			M.open_cppman_for(value)
		end,
	})

	-- mount/open the component
	input:mount()

	-- unmount component when cursor leaves buffer
	input:on(event.BufLeave, function()
		input:unmount()
	end)

	vim.keymap.set("n", "q", ":q!<cr>", { silent = true, buffer = true })
	vim.keymap.set("n", "<ESC>", ":q!<cr>", { silent = true, buffer = true })
end

-- Pops up a window containing the results of the search
M.open_cppman_for = function(word_to_search)
	local popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "double",
			text = {
				top = "[cppman]",
				top_align = "center",
			}
		},
		position = "50%",
		size = {
			width = "80%",
			height = "60%",
		},
	})

	-- mount/open the component
	popup:mount()

	-- unmount component when cursor leaves buffer
	popup:on(event.BufLeave, function()
		popup:unmount()

		current_page = nil
		for i=0, #stack do stack[i]=nil end
	end)

	-- Set content
	local wininfo = vim.fn.getwininfo(popup.winid)[1]
	local manwidth = wininfo.width - 4;

	reload(manwidth, word_to_search)

	current_page = word_to_search

	vim.keymap.set("n", "q", ":q!<cr>", { silent = true, buffer = true })

	vim.keymap.set("n", "K", loadNewPage, { silent = true, buffer = true })
	vim.keymap.set("n", "<C-]>", loadNewPage, { silent = true, buffer = true })
	vim.keymap.set("n", "<2-LeftMouse>", loadNewPage, { silent = true, buffer = true })


	vim.keymap.set("n", "<C-T>", backToPrevPage, { silent = true, buffer = true })
	vim.keymap.set("n", "<RightMouse>", backToPrevPage, { silent = true, buffer = true })
end

return M
