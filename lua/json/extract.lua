local M = {}

local function extract_json()
	local line = vim.api.nvim_get_current_line()

	local raw_jsons = {}

	local start_at = 0
	local need_right_paren = 0
	local parsing_str = false
	local skip_next = false

	for i = 1, #line do
		local c = line:sub(i, i)
		if skip_next then
			skip_next = false
			goto continue
		end
		if parsing_str then
			if c == "\\" then
				skip_next = true
			elseif c == '"' then
				parsing_str = false
			end
			goto continue
		end
		if c == "{" then
			if need_right_paren == 0 then
				start_at = i
			end
			need_right_paren = need_right_paren + 1
		elseif c == "}" then
			if need_right_paren > 0 then
				need_right_paren = need_right_paren - 1
				if need_right_paren == 0 then
					table.insert(raw_jsons, line:sub(start_at, i))
					print(line:sub(start_at, i))
				end
			end
		elseif c == '"' then
			parsing_str = true
		end
		::continue::
	end

	return raw_jsons
end

local window_instance
local buff_arr = {}
local title_buf
local title_win
local curr_index = 1

local function update_title(curr, count)
	local title_content = " " .. curr .. "/" .. count .. " "
	vim.api.nvim_win_set_width(title_win, #title_content)
	vim.api.nvim_buf_set_lines(title_buf, 0, 1, false, { title_content })
end

local function update_content(buff)
	vim.api.nvim_win_set_buf(window_instance, buff)
end

local function view_objects(contents)
	if #contents == 0 then
		return
	end

	if window_instance ~= nil and vim.api.nvim_win_is_valid(window_instance) then
		vim.api.nvim_win_close(window_instance, { force = true })
	end

	curr_index = 1
	for i = 1, #contents do
		local buff = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(buff, "filetype", "json")
		vim.api.nvim_buf_set_name(buff, "json.nvim[" .. i .. "].json")
		vim.api.nvim_buf_set_lines(buff, 0, 1, false, { contents[i] })
		table.insert(buff_arr, buff)
	end

	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.8)
	local win_width = math.ceil(width * 0.8)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2 - 1)
	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		col = col,
		row = row + 2,
		border = "rounded",
		zindex = 100,
	}

	local win = vim.api.nvim_open_win(buff_arr[1], true, opts)
	vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal")
	vim.api.nvim_buf_set_text(buff_arr[1], 0, 0, 0, 0, { "" })
	window_instance = win

	local group = vim.api.nvim_create_augroup("json.title_win", { clear = true })
	for _, buff in pairs(buff_arr) do
		vim.api.nvim_create_autocmd("WinClosed", {
			group = group,
			buffer = buff,
			once = true,
			callback = function()
				print("buffs will be clear")
				for _, b in pairs(buff_arr) do
					vim.api.nvim_buf_delete(b, { force = true })
				end
				curr_index = 1
				buff_arr = {}
			end,
		})
	end

	if #contents <= 1 then
		return
	end

	vim.cmd("redraw")

	local title_opt = {
		style = "minimal",
		win = win,
		relative = "win",
		height = 1,
		width = 1,
		focusable = false,
		noautocmd = true,
		col = 1,
		row = -1,
		zindex = 101,
	}

	curr_index = 1
	title_buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_option(title_buf, "bufhidden", "wipe")
	title_win = vim.api.nvim_open_win(title_buf, false, title_opt)
	update_title(1, #contents)

	group = vim.api.nvim_create_augroup("json.title_win", { clear = true })

	for _, buf in pairs(buff_arr) do
		vim.api.nvim_create_autocmd("WinClosed", {
			group = group,
			buffer = buf,
			once = true,
			callback = function()
				print("title will close")
				vim.api.nvim_win_close(title_win, true)
			end,
		})
		vim.api.nvim_buf_set_keymap(buf, "n", "]]", ":JsonNext<cr>", {})
		vim.api.nvim_buf_set_keymap(buf, "n", "[[", ":JsonPrev<cr>", {})
	end
end

function M.next_json_object()
	if window_instance == nil then
		return
	end
	if vim.api.nvim_win_is_valid(window_instance) and #buff_arr > 1 then
		curr_index = curr_index + 1
		if curr_index > #buff_arr then
			curr_index = 1
		end
		update_title(curr_index, #buff_arr)
		update_content(buff_arr[curr_index])
	end
end

function M.prev_json_object()
	if window_instance == nil then
		return
	end
	if vim.api.nvim_win_is_valid(window_instance) and #buff_arr > 1 then
		curr_index = curr_index - 1
		if curr_index == 0 then
			curr_index = #buff_arr
		end
		update_title(curr_index, #buff_arr)
		update_content(buff_arr[curr_index])
	end
end


function M.extract()
	local result = extract_json()
	view_objects(result)
end

return M
