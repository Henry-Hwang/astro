local sort = {}
local buffer = require "user.plugins.sort.buffer"

function sort.trim_buffer()
  buffer.trim()
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

function sort.grep_path_quickfix(pattern, path)
  -- Build the grep command
  local grep_command = string.format("grep -nr '%s' '%s'", pattern, path)

  -- Run grep command and capture the output
  local grep_output = vim.fn.system(grep_command)

  -- Split the output into lines
  local lines = vim.split(grep_output, "\n")

  -- Clear the existing quickfix list
  vim.fn.setqflist({}, "r")

  -- Populate the quickfix list with the lines
  local quickfix_list = {}
  for _, line in ipairs(lines) do
    if line ~= "" then
      print(line)
      local filename, linenumber, text = line:match("^(.-):(%d+):(.+)$")
      if filename and linenumber and text then
        table.insert(quickfix_list, {filename = filename, lnum = linenumber, text = text})
      end
    end
  end
  vim.fn.setqflist(quickfix_list, "a")
  vim.cmd("copen")
end

function sort.search_path_files(path, pattern)
  local files = vim.fn.readdir(path)
  local qflist = {}
  -- Iterate over the files and create quickfix entries
  for _, file in ipairs(files) do
    table.insert(qflist, {filename = file})
  end

  -- Set the quickfix list
  vim.fn.setqflist(qflist)
  vim.cmd("copen")
end

function sort.fzf_quickfix()
  -- Run FZF command and capture the output
  local fzf_command = "fzf"
  local fzf_output = vim.fn.system(fzf_command)

  -- Split the output into lines
  local lines = vim.split(fzf_output, "\n")

  -- Clear the existing quickfix list
  vim.fn.setqflist({}, "r")

  -- Populate the quickfix list with the lines
  local quickfix_list = {}
  for _, line in ipairs(lines) do
    if line ~= "" then
      table.insert(quickfix_list, {filename = line})
    end
  end
  vim.fn.setqflist(quickfix_list, "a")
end

function sort.regex_buf_quickfix(pattern)
  local lines = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local regex = vim.regex(pattern)

  buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  -- Iterate over each line in the buffer
  for line_number, line_text in ipairs(buffer_lines) do
    -- Check if the line contains the pattern "sample"
    -- if string.find(line_text, pattern) then
    if regex:match_str(line_text) then
      -- Create a table representing the quickfix entry and add it to the lines table
      table.insert(lines, {
        filename = vim.api.nvim_buf_get_name(bufnr),
        lnum = line_number,
        text = line_text
      })
    end
  end

  -- Set the lines in the quickfix list
  vim.fn.setqflist(lines)

  -- vim.cmd("cwindow")
  vim.cmd("copen")
end


function sort.find_buf_quickfix(word)
  local lines = {}
  local bufnr = vim.api.nvim_get_current_buf()

  -- Iterate over each line in the buffer
  for line_number, line_text in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if string.find(line_text, word) then
      -- Create a table representing the quickfix entry and add it to the lines table
      table.insert(lines, {
        filename = vim.api.nvim_buf_get_name(bufnr),
        lnum = line_number,
        text = line_text
      })
    end
  end

  -- Set the lines in the quickfix list
  vim.fn.setqflist(lines)

  -- vim.cmd("cwindow")
  vim.cmd("copen")
end

-- Function to populate quickfix list with file names in current directory
function sort.populateQuickfix1(pattern)
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
function sort.popup_search(pattern, path)
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
        top = "[Search..]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
      prompt = "> ",
      default_value = pattern,
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


function sort.popup_buffers()
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

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

  local ok = popup:map("n", "<cr>", function(bufnr)
    local buffer_id = buffer.retrieve_id_from_cursor_line()
    vim.api.nvim_set_current_buf(tonumber(buffer_id))
    -- vim.cmd(":b " .. buffer_id)
  end, { noremap = true })
  -- set content
  local buffer_list = buffer.enumerate_and_sort()
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, buffer_list)

  vim.bo[popup.bufnr].modifiable = false
  vim.bo[popup.bufnr].readonly = true
end

return sort

