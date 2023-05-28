local sort = {}

function sort.trim_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local new_lines = {}

  for _, line in ipairs(lines) do
    -- Trim leading and trailing whitespace
    local trimmed_line = string.gsub(line, "^%s*(.-)%s*$", "%1")

    -- Only add non-blank lines to the new_lines table
    if trimmed_line ~= "" then
      table.insert(new_lines, trimmed_line)
    end
  end

  -- Replace the buffer contents with the trimmed lines
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

function sort.regex_keep_match(pattern)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Prompt the user to enter a regular expression pattern to match
  -- local pattern = vim.fn.input("regular expression: ")

  -- Create a regular expression object from the pattern
  local regex = vim.regex(pattern)

  local new_lines = {}

  for _, line in ipairs(lines) do
    if regex:match_str(line) then
      table.insert(new_lines, line)
    end
  end

  -- Replace the buffer contents with the matched lines
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

function sort.regex_delete_match(pattern)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Create a regular expression object from the pattern
  local regex = vim.regex(pattern)

  local new_lines = {}

  for _, line in ipairs(lines) do
    if not regex:match_str(line) then
      table.insert(new_lines, line)
    end
  end

  -- Replace the buffer contents with the non-matching lines
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end


-- Function to populate quickfix list with file names in current directory
function sort.populateQuickfix()
  local files = vim.fn.readdir(vim.fn.getcwd())
  local quickfix_list = {}
  
  for _, file in ipairs(files) do
    table.insert(quickfix_list, {filename = file})
  end
  
  vim.fn.setqflist(quickfix_list)
  vim.cmd("copen")
end

-- Command to trigger the plugin
-- vim.cmd("command! -nargs=0 FileList lua populateQuickfix()")

-- Function to create a floating window and show file names in current directory
function sort.showFileList1()
  local files = vim.fn.readdir(vim.fn.getcwd())
  local file_list = {}

  for _, file in ipairs(files) do
    table.insert(file_list, file)
  end

  -- Create a new floating window
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winnr = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    width = 40,
    height = #file_list,
    row = 2,
    col = 2,
    focusable = true,
    border = 'single'
  })

  -- Set the buffer content with file names
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, file_list)

  -- Set the floating window options
  vim.api.nvim_win_set_option(winnr, 'wrap', false)
  vim.api.nvim_win_set_option(winnr, 'winblend', 0)

  -- Set the highlight group for the floating window
  vim.cmd("highlight FileListWindow guibg=black guifg=white")

  -- Set autocommand to close the window when leaving the buffer
  vim.cmd("autocmd BufLeave <buffer> :call nvim_win_close(" .. winnr .. ", v:true)")

  -- Focus the floating window
  vim.api.nvim_set_current_win(winnr)
end

-- Function to create a floating window and show file names in current directory
function sort.showFileList()
  local files = vim.fn.readdir(vim.fn.getcwd())
  local file_list = {}

  for _, file in ipairs(files) do
    table.insert(file_list, file)
  end

  -- Create a new floating window
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winnr = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    width = 40,
    height = #file_list,
    row = 2,
    col = 2,
    focusable = true,
    border = 'single'
  })
  print("the float win ID: " .. winnr)
  -- Set the buffer content with file names
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, file_list)

  -- Set the floating window options
  vim.api.nvim_win_set_option(winnr, 'wrap', false)
  vim.api.nvim_win_set_option(winnr, 'winblend', 0)

  -- Set the highlight group for the floating window
  vim.cmd("highlight FileListWindow guibg=black guifg=white")

  -- Set autocommand to close the window when leaving the buffer
  vim.cmd("autocmd BufLeave <buffer> :call nvim_win_close(" .. winnr .. ", v:true)")

  -- Set key mapping to jump to the selected file
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', ":lua jumpToFile()<CR>", {
    silent = true,
    noremap = true
  })

  -- Define the jumpToFile function
  _G.jumpToFile = function()
    local selected_line = vim.api.nvim_win_get_cursor(winnr)[1]
    local selected_file = file_list[selected_line]
    vim.api.nvim_command("edit " .. selected_file)
    print("the close win ID: " .. winnr)
    -- vim.api.nvim_win_close(winnr, true)
  end

  -- Focus the floating window
  vim.api.nvim_set_current_win(winnr)
end

-- Command to trigger the plugin
-- vim.cmd("command! -nargs=0 FileList lua showFileList()")

-- Function to create a floating window and show the buffer list
function sort.showBufferList()
  -- Get the list of buffers
  local buffers = vim.api.nvim_list_bufs()
  local buffer_list = {}

  -- Iterate over the buffers and retrieve the buffer names
  for _, bufnr in ipairs(buffers) do
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
    table.insert(buffer_list, name)
  end

  -- Sort the buffer list by most recent use
  -- table.sort(buffer_list, function(a, b)
  --   local a_last_used = vim.fn.getbufinfo(vim.fn.bufnr(a)).lastused
  --   local b_last_used = vim.fn.getbufinfo(vim.fn.bufnr(b)).lastused
  --   return a_last_used > b_last_used
  -- end)

  -- Calculate the center position of the main window
  local main_win = vim.api.nvim_get_current_win()
  local main_width = vim.api.nvim_win_get_width(main_win)
  local main_height = vim.api.nvim_win_get_height(main_win)
  local float_width = 40
  local float_height = #buffer_list

  local row = math.floor((main_height - float_height) / 2)
  local col = math.floor((main_width - float_width) / 2)

  -- Create a new floating window
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winnr = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    width = float_width,
    height = float_height,
    row = row,
    col = col,
    focusable = true,
    border = 'single'
  })

  -- Set the buffer content with buffer names
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, buffer_list)

  -- Set the floating window options
  vim.api.nvim_win_set_option(winnr, 'wrap', false)
  vim.api.nvim_win_set_option(winnr, 'winblend', 0)

  -- Set the highlight group for the floating window
  vim.cmd("highlight BufferListWindow guibg=black guifg=white")

  -- Set autocommand to close the window when leaving the buffer
  vim.cmd("autocmd BufLeave <buffer> :call nvim_win_close(" .. winnr .. ", v:true)")

  -- Set key mapping to jump to the selected buffer
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', ":lua jumpToBuffer(" .. winnr .. ")<CR>", {
    silent = true,
    noremap = true
  })

  -- Focus the floating window
  vim.api.nvim_set_current_win(winnr)
end

-- Define the jumpToBuffer function
_G.jumpToBuffer = function(winnr)
  local selected_line = vim.api.nvim_win_get_cursor(winnr)[1]
  local buffer_list = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local selected_buffer = buffer_list[selected_line]
  vim.cmd("buffer " .. selected_buffer)
  vim.cmd("close")
end

-- Command to trigger the plugin
-- vim.cmd("command! -nargs=0 BufferList lua showBufferList()")
return sort

