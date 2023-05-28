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
function sort.popup_input()
  local Input = require("nui.input")
  local event = require("nui.utils.autocmd").event

  local input = Input({
    position = "50%",
    size = {
      width = 20,
    },
    border = {
      style = "single",
      text = {
        top = "[Howdy?]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
      prompt = "> ",
      default_value = "Hello",
      on_close = function()
        print("Input Closed!")
      end,
      on_submit = function(value)
        print("Input Submitted: " .. value)
      end,
    })

  -- mount/open the component
  input:mount()

  -- unmount component when cursor leaves buffer
  input:on(event.BufLeave, function()
    input:unmount()
  end)
end

function sort_buffers_by_recent_use(buffers)


    -- switching buffers and opening 'buffers' in quick succession
    -- can lead to incorrect sort as 'lastused' isn't updated fast
    -- enough (neovim bug?), this makes sure the current buffer is
    -- always on top (#646)
    -- Hopefully this gets solved before the year 2100
    -- DON'T FORCE ME TO UPDATE THIS HACK NEOVIM LOL
    local future = os.time({ year = 2100, month = 1, day = 1, hour = 0, minute = 00 })
    local get_unixtime = function(buf)
      if buf.flag == "%" then
        return future
      elseif buf.flag == "#" then
        return future - 1
      else
        return buf.info.lastused
      end
    end
    table.sort(buffers, function(a, b)
      return get_unixtime(a) > get_unixtime(b)
    end)
  return buffers
end

function sym_buffer(buf)
  local alt_buf = vim.fn.bufnr("#")
  local cur_buf = vim.fn.bufnr("%")
  local arg_buf = vim.fn.bufnr("a")
  local buf_list_buf = vim.fn.bufnr("b")
  local last_buf = vim.fn.bufnr("l")
  local last_accessed_buf = vim.fn.bufnr("s")
  print("Alternate Buffer:", alt_buf)
  print("Current Buffer:", cur_buf)
  print("Argument List Buffer:", arg_buf)
  print("Buffer List Buffer:", buf_list_buf)
  print("Last Buffer:", last_buf)
  print("Last Accessed Buffer:", last_accessed_buf)
  print("Current Buffer--:", buf)

  if buf == alt_buf then
    return "#"
  elseif buf == current then
    return "%"
  elseif buf == arg_buf then
    return "a"
  elseif buf == last_buf then
    return "l"
  elseif buf == last_accessed_buf then
    return "s"
  end
  return " "
end

function sort.popup_buffers()
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event
  local buffers = vim.api.nvim_list_bufs()
  local buffer_list = {}
  local buffer_show = {}


  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
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

  for _, buf in ipairs(buffers) do
    local path = vim.api.nvim_buf_get_name(buf)
    path = string.gsub(path, "^%s*(.-)%s*$", "%1")
    if path ~= "" then
      table.insert(buffer_list, buf)
    end
  end
  -- Sort the buffer list by most recent use
  table.sort(buffer_list, function(a, b)
    local a_last_used = vim.api.nvim_buf_get_var(a, "open_timestamp")
    local b_last_used = vim.api.nvim_buf_get_var(b, "open_timestamp")
    return tonumber(a_last_used) > tonumber(b_last_used)
  end)

  if #buffer_list > 1 then
    table.remove(buffer_list, 1)
  end

  for _, buf in ipairs(buffer_list) do
    local path = vim.api.nvim_buf_get_name(buf)
    path = string.gsub(path, "^%s*(.-)%s*$", "%1")
    if path ~= "" then
      local base = vim.fn.fnamemodify(path, ':t')
      local dir = vim.fn.fnamemodify(path, ':h')
      local modified = ' '
      if 1 == vim.fn.getbufvar(buf, "&modified") then
        modified = '*'
      end
      -- local symbol = sym_buffer(buf)
      -- local time = vim.api.nvim_buf_get_var(buf, "open_timestamp")
      -- local info = buf.. ":" .. symbol .. ": " .. modified .. ": " .. base .. ": " .. dir
      local info = string.format("%2d: %s: %s: %s", buf, modified, base, dir)
      table.insert(buffer_show, info)
    end
  end

  local ok = popup:map("n", "<cr>", function(bufnr)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_number = cursor_pos[1]
    local buffer_info = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

    local separator_pos = string.find(buffer_info, ":")
    local buffer_id = 1
    if separator_pos then
      buffer_id = string.sub(buffer_info, 1, separator_pos - 1)
      local buffer_name = string.sub(buffer_info, separator_pos + 2)
      -- return buffer_id, buffer_name
    end

    print("Enter pressed in Normal mode! " .. buffer_id)
    vim.api.nvim_set_current_buf(tonumber(buffer_id))
    -- vim.cmd(":b " .. buffer_id)
  end, { noremap = true })
  -- set content
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, buffer_show)
end

return sort

