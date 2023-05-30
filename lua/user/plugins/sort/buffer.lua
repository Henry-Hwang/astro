local buffer = {}

function buffer.retrieve_info_from_cursor_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_number = cursor_pos[1]
    local buffer_info = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
    local separator_pos = string.find(buffer_info, ":")
    local bufnr = 1
    if separator_pos then
      bufnr = tonumber(string.sub(buffer_info, 1, separator_pos - 1))
      -- local buffer_name = string.sub(buffer_info, separator_pos + 2)
    end

  local info = vim.fn.getbufinfo(bufnr)[1]
  return bufnr, info.lnum
end

function buffer.format_lines(bufnr, path)
  local base = vim.fn.fnamemodify(path, ':t')
  local dir = vim.fn.fnamemodify(path, ':h')
  local info = vim.fn.getbufinfo(bufnr)[1]

  -- local test = vim.fn.getbufvar(bufnr, "&linecount")
  if 1 == vim.fn.getbufvar(bufnr, "&modified") then
    return string.format("%2d: %s + .. %s", bufnr, base, dir)
  else
    return string.format("%2d: %s   .. %s, %s, %s", bufnr, base, dir, info.lnum, info.lastused)
  end
end

function buffer.enumerate_and_sort()
  local buffers = vim.api.nvim_list_bufs()
  local buffer_list = {}
  local show_list = {}

  for _, buf in ipairs(buffers) do
    local path = vim.api.nvim_buf_get_name(buf)
    path = string.gsub(path, "^%s*(.-)%s*$", "%1")
    if vim.api.nvim_buf_is_loaded(buf) and path ~= "" then
      table.insert(buffer_list, buf)
    end
  end
  -- Sort the buffer list by most recent use
  table.sort(buffer_list, function(a, b)
    local binfo, ainfo = vim.fn.getbufinfo(b)[1], vim.fn.getbufinfo(a)[1]
    return ainfo.lastused > binfo.lastused
  end)

  if #buffer_list > 1 then
    -- Move the first to last
    table.insert(buffer_list, table.remove(buffer_list, 1))
  end

  for _, buf in ipairs(buffer_list) do
    local path = vim.api.nvim_buf_get_name(buf)
    table.insert(show_list, buffer.format_lines(buf, path))
  end
  return show_list
end

function buffer.trim()
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

function buffer.match_lines_to_quickfix_list(word)
  local qfix_lines = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  -- Iterate over each line in the buffer
  for line_number, line_text in ipairs(buffer_lines) do
    if string.find(line_text, word) then
      -- Create a table representing the quickfix entry and add it to the lines table
      table.insert(qfix_lines, {
        filename = vim.api.nvim_buf_get_name(bufnr),
        lnum = line_number,
        text = line_text
      })
    end
  end
  return qfix_lines
end

return buffer
