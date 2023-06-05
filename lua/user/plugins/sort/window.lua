local window = {}

function window.toggle_quickfix()
  -- Check if the quickfix window is currently open
  qf = vim.fn.getwininfo(vim.fn.win_getid())[1]
  if 1 == qf.quickfix then
    -- Close the quickfix window
    vim.cmd("cclose")
  else
    -- Open the quickfix window
    vim.cmd("copen")
    window.set_height()
  end
end

function window.qfix_open(list)
  vim.api.nvim_notify('quickfix: ' .. #list .. ' found', vim.log.levels.INFO, {})
  if #list > 0 then
    vim.fn.setqflist(list)
    vim.cmd("copen")
    window.set_height()
  end
end

function window.set_height()
  local WinId = vim.fn.getqflist({winid = 0}).winid
  local width = vim.api.nvim_win_get_width(WinId)
  local qf_list = vim.fn.getqflist()
  local height = #qf_list
  -- vim.api.nvim_notify('height: ' .. height, vim.log.levels.INFO, {})
  if height <= 10 then
    height = 10
  elseif height > 30 then
    height = 30
  end

  local config = {
    width = width,    -- Use 0 to keep the width unchanged
    height = height,
    relative = 'editor',
    row = vim.o.lines - height - 1,
    col = 0,
    focusable = false,
  }

  vim.api.nvim_win_set_config(WinId, config)
end

-- Function to set the quickfix window at float mode
function window.float_quickfix()
  local quickfix_winid = vim.fn.getqflist({winid = 0}).winid

  -- Check if the quickfix window exists
  if quickfix_winid ~= -1 then
    -- Get the current window dimensions
    local width = vim.api.nvim_win_get_width(quickfix_winid)
    local height = vim.api.nvim_win_get_height(quickfix_winid)

    -- Calculate the float window position
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Set the quickfix window at float mode
    vim.api.nvim_win_set_config(quickfix_winid, {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
      style = "minimal",
      focusable = false,
      border = "single",
    })
  end
end

return window
