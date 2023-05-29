local buffer = {}

function buffer.retrieve_id_from_cursor_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_number = cursor_pos[1]
    local buffer_info = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
    local separator_pos = string.find(buffer_info, ":")
    local buffer_id = 1
    if separator_pos then
      buffer_id = string.sub(buffer_info, 1, separator_pos - 1)
      -- local buffer_name = string.sub(buffer_info, separator_pos + 2)
    end

  return buffer_id
end

function buffer.format_string(bufnr, path)
  local base = vim.fn.fnamemodify(path, ':t')
  local dir = vim.fn.fnamemodify(path, ':h')

  if 1 == vim.fn.getbufvar(bufnr, "&modified") then
    return string.format("%2d: %s + .. %s", bufnr, base, dir)
  else
    return string.format("%2d: %s   .. %s", bufnr, base, dir)
  end
end

function buffer.enumerate_and_sort()
  local buffers = vim.api.nvim_list_bufs()
  local buffer_list = {}
  local buffer_show = {}

  for _, buf in ipairs(buffers) do
    local path = vim.api.nvim_buf_get_name(buf)
    path = string.gsub(path, "^%s*(.-)%s*$", "%1")
    if path ~= "" then
      table.insert(buffer_list, buf)
    end
  end
  -- Sort the buffer list by most recent use
  table.sort(buffer_list, function(a, b)
    local success, a_last_used = pcall(vim.api.nvim_buf_get_var, a, "open_timestamp")
    if not success then
      a_last_used = 0
    end
    local success, b_last_used = pcall(vim.api.nvim_buf_get_var, b, "open_timestamp")
    if not success then
      b_last_used = 0
    end
    return tonumber(a_last_used) > tonumber(b_last_used)
  end)

  if #buffer_list > 1 then
    table.remove(buffer_list, 1)
  end

  for _, buf in ipairs(buffer_list) do
    local path = vim.api.nvim_buf_get_name(buf)
    path = string.gsub(path, "^%s*(.-)%s*$", "%1")
    if path ~= "" then
      local info = buffer.format_string(buf, path)
      table.insert(buffer_show, info)
    end
  end

  return buffer_show
end

return buffer