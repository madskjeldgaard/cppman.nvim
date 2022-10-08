local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local Popup = require("nui.popup")

local M = {}

local function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
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
	end)

	-- Set content
	local wininfo = vim.fn.getwininfo(popup.winid)[1]
	local manwidth = wininfo.width - 4;
	local cmd = string.format([[r! cppman --force-columns %s '%s' ]], manwidth, word_to_search)
	vim.cmd(cmd) -- Set buffer with cppman contents
	vim.cmd("0") -- Go to top of document
	vim.bo.filetype = "man"

	vim.keymap.set("n", "q", ":q!<cr>", { buffer = true })

end

return M
