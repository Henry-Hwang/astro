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
    end
end

local api = vim.api

-- Function to set the quickfix window at float mode
function window.float_quickfix()
  local quickfix_winid = vim.fn.getqflist({winid = 0}).winid

  -- Check if the quickfix window exists
  if quickfix_winid ~= -1 then
    -- Get the current window dimensions
    local width = api.nvim_win_get_width(quickfix_winid)
    local height = api.nvim_win_get_height(quickfix_winid)

    -- Calculate the float window position
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Set the quickfix window at float mode
    api.nvim_win_set_config(quickfix_winid, {
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