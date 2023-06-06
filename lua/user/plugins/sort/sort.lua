local sort = {}
local buffer = require "user.plugins.sort.buffer"
local window = require "user.plugins.sort.window"

function sort.trim_buffer()
  buffer.trim()
end

function strim(str)
  return string.gsub(string.gsub(str, "\r$", ""), "^%s*(.-)%s*$", "%1")
end

function sort.toggle_quickfix()
  window.toggle_quickfix()
end

function sort.path_join(...)
  local separator = package.config:sub(1,1) -- Get the path separator based on the current platform
  local path = table.concat({...}, separator)
  return path:gsub(separator.."+", separator):gsub(separator.."$", "")
end

function sort.tcd_popup(arguments)
  local path = arguments[2]
	vim.cmd(":tcd " .. path)
end

function sort.nvim_userdir()
  local userdir = "~/.config/nvim/lua/user"
  if vim.fn.has('win32') == 1 then
		userdir = vim.fn.getenv("LOCALAPPDATA") .. "/nvim/lua/user"
	end
	vim.cmd(":Neotree filesystem position=float dir=" .. userdir)
end

function sort.print(log_string)
  local log_buffer_name = "lua_nvim.log"
  local log_buffer = vim.fn.bufnr(log_buffer_name)
  if log_buffer == -1 then
    log_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(log_buffer, log_buffer_name)
  end
  local lines = vim.split(log_string, "\n")
  vim.api.nvim_buf_set_lines(log_buffer, -1, -1, false, lines)
end

function find_top_dir(path)
  local separator = package.config:sub(1, 1) -- Get the path separator based on the current operating system
  local current = path
  for i = 1, 10, 1 do
    if is_top_dir(current) then
      return current
    end
    current = current:gsub(separator .. "[^" .. separator .. "]+$", "")
  end
  return path
end

function sort.find_word_top(arguments)
  local pattern = arguments[1]
  local path = arguments[2]
  local separator = package.config:sub(1, 1) -- Get the path separator based on the current operating system

  path = find_top_dir(path)
  sort.grep_quickfix({pattern, path})
end

function sort.grep_quickfix(arguments)
  local pattern = arguments[1]
  local path = arguments[2]

  if pattern == "" then
      return
  end

  vim.fn.setqflist({}, "r")
  local qfix_list = {}
  local command = string.format("rg --vimgrep --smart-case --no-column %s %s", pattern, path)
  -- vim.api.nvim_notify(command, vim.log.levels.INFO, {})
  local output = vim.fn.system(command)
  local lines = vim.split(output, "\n")
  for _, line in ipairs(lines) do
    if line ~= "" then
      local filename, linenumber, text = line:match("^(.-):(%d+):(.+)$")
      if filename and linenumber and text then
        table.insert(qfix_list, {filename = filename, lnum = linenumber, text = text})
      end
    end
  end

  window.qfix_open(qfix_list)
end

function sort.find_word(arguments)
  local pattern = arguments[1]
  if pattern ~= "" then
    local qfix_list = buffer.regex_lines_to_qfix(pattern)
    window.qfix_open(qfix_list)
  end
end

function is_top_dir(path)
  if vim.fn.has('win32') == 1 then
    -- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/dir
    command = 'dir /ad /b ' ..path
  else
    command = 'find ' ..path.. ' -type d -maxdepth 1'
  end

  local files = vim.fn.systemlist(command)
  for _, file in ipairs(files) do
    for _, p in ipairs({"[/\\]?%.git$", "[/\\]?%.svn$"}) do
      if string.match(strim(file), p) then
        vim.api.nvim_notify('top directory : ' ..path , vim.log.levels.INFO, {})
        return true 
      end
    end
  end

  return false
end


function sort.find_files(path)
  local new = sort.path_join(path, pattern)
  local command = 'find ' .. path .. ' -type f -not -path "/*/.git/*"'
  if vim.fn.has('win32') == 1 then
    -- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/dir
    -- command = 'dir ' .. path .. ' /b/s/a:-h'
    command = 'dir ' ..path.. '/B /S /A:-H /A:-D /A:-L | findstr /V /I /C:".git" /C:".gitignore"'
  end

  return vim.fn.systemlist(command)
end

function sort.find_files_top(arguments)
  local path = arguments[2]
  path = find_top_dir(path)
  sort.find_files_path({"", path})
end

function sort.find_files_path(arguments)
  local _, path = arguments[1], arguments[2]
  local files = sort.find_files(path)
  local qfix_list = {}
  for _, file in ipairs(files) do
    table.insert(qfix_list, {filename =strim(file)})
  end
  window.qfix_open(qfix_list)
end

function sort.find_and_keep(pattern)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local regex = vim.regex(pattern)
  local new_lines = {}
  for _, line in ipairs(lines) do
    if regex:match_str(line) then
      table.insert(new_lines, line)
    end
  end
  buffer.create_with_data(new_lines)
end

function sort.find_and_remove(pattern)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local regex = vim.regex(pattern)
  local new_lines = {}
  for _, line in ipairs(lines) do
    if not regex:match_str(line) then
      table.insert(new_lines, line)
    end
  end
  buffer.create_with_data(new_lines)
end

function sort.float_information(title, entries)
  vim.fn.setqflist({}, "r", {title = title, items = entries})
  vim.lsp.util.open_floating_preview(entries)
end

function sort.open_in_explore(path)
  local command
  if vim.fn.has('win32') == 1 then
    command = 'start ' .. path
  else
    command = 'echo ..'
  end
  os.execute(command)
  vim.api.nvim_echo({{"Open in location: " ..path, "Title"}}, true, {})
end

function sort.save_buffer(arguments)
    filepath = arguments[2]
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local file = io.open(filepath, "w")

    if file then
        for _, line in ipairs(lines) do
            file:write(line .. "\n")
        end
        file:close()
        vim.api.nvim_command("edit " .. vim.fn.fnameescape(filepath))
    else
        print("Error: Unable to save buffer to file.")
    end
end

function sort.save_buffer_popup(pattern, path)
  sort.popup_caller({pattern, path}, sort.save_buffer)
end

function sort.popup_caller(arguments, callback)
  local Input = require("nui.input")
  local event = require("nui.utils.autocmd").event
  local default_value = table.concat(arguments, "|")
  vim.api.nvim_notify("width: " .. #default_value, vim.log.levels.INFO, {})
  local input = Input({
    position = "50%",
    size = { width = #default_value + 10, },
    border = { 
      style = "single",
      text = { top = "[Search]", top_align = "center",},
    },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal",},
  }, {
      prompt = "> ", default_value = default_value,
      on_close = function()
        print("Input Closed!")
      end,
      on_submit = function(value)
        local values = {}
        for v in string.gmatch(value, "([^|]+)") do
          table.insert(values, v)
        end
        -- sort.print({"tag:0002---", values[1], values[2], "tag: end----"})
        callback(values)
      end,
    })

  -- mount/open the component
  input:mount()

  input:map("n", "<Esc>", function()
    input:unmount()
  end, { noremap = true })

  -- unmount component when cursor leaves buffer
  input:on(event.BufLeave, function()
    input:unmount()
  end)
end


function sort.list_buf_popup()
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local popup = Popup({
    relative = 'editor',
    enter = true,
    focusable = true,
    border = {
      -- padding = {top = 0, bottom = 1,left = 0,right = 0,},
      style = "rounded",
      text = {top = " Buffers List ", top_align = "center", bottom = "Don't Waste Time",bottom_align = "center",},
    },
    -- zindex = 50,
    position = "50%",
    size = {width = "80%", height = "60%",},
    buf_options = {
      modifiable = true,
      readonly = false,
    },
    win_options = {
      -- winblend = 5,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  })
  -- mount/open the component
  popup:mount()

  -- unmount component when cursor leaves buffer
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)
  
  -- popup.border:set_highlight("lua")
  
  local ok = popup:map("n", "<cr>", function(bufnr)
    local id, lnum = buffer.retrieve_info_from_cursor_line()
    vim.api.nvim_set_current_buf(id)
    vim.api.nvim_win_set_cursor(0, {lnum, 0})
    -- vim.cmd(":b " .. id)
  end, { noremap = true })
  -- set content
  local buffer_list = buffer.enumerate_and_sort()
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, buffer_list)

  vim.bo[popup.bufnr].modifiable = false
  -- vim.bo[popup.bufnr].readonly = true
end

function sort.most_paths()
  local Menu = require("nui.menu")
  local event = require("nui.utils.autocmd").event

  local menu = Menu({
    position = "50%",
    size = {
      width = 60,
      height = 15,
    },
    border = {
      style = "single",
      text = {
        top = "[Choose-an-Element]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
      lines = {
        Menu.item("C:\\Users\\hhuang\\AppData\\Local\\nvim\\lua\\user"),
        Menu.item("C:\\work\\customer\\meizu"),
        Menu.item("C:\\work\\customer\\xiaomi"),
        Menu.item("C:\\work\\src\\capi_cirrus_sp\\myspf"),
        Menu.item("C:\\work\\src\\aus\\github\\Cirrus-Logic-Software\\claw-monorepo"),
        Menu.item("C:\\work\\src\\aus\\scs"),
        Menu.item("C:\\work\\src\\aus\\cirrus\\tools"),
        Menu.item("C:\\work\\src\\aus\\bitbuket\\AmpWorkstation"),
        Menu.item("C:\\work\\src\\aus\\amps"),
        Menu.item("C:\\work\\src\\aus\\system-test"),
        Menu.item("C:\\work\\src\\Android\\cirrus\\app\\src\\main\\cpp\\tools"),
        Menu.item("C:\\work\\src\\hvim"),
        Menu.item("C:\\work\\tools\\Bin"),
        Menu.item("C:\\ProgramData\\Cirrus\\ Logic\\SCS_1.7"), -- keep a \ in the line to representing a space
        Menu.item("C:\\Users\\hhuang\\scs_workspaces"),
        Menu.item("C:\\Users\\hhuang\\AppData\\Local\\Cirrus\\ Logic"), -- keep a \ in the line to representing a space
        Menu.item("C:\\Users\\hhuang\\SoundClearStudio\\v1.7\\log"),
        -- Menu.item("Hydrogen (H)"),
        -- Menu.item("Carbon (C)"),
        -- Menu.item("Nitrogen (N)"),
        -- Menu.separator("Noble-Gases", {
        --   char = "-",
        --   text_align = "right",
        -- }),
        -- Menu.item("Helium (He)"),
        -- Menu.item("Neon (Ne)"),
        -- Menu.item("Argon (Ar)"),
      },
      max_width = 20,
      keymap = {
        focus_next = { "j", "<Down>", "<Tab>" },
        focus_prev = { "k", "<Up>", "<S-Tab>" },
        close = { "<Esc>", "<C-c>" },
        submit = { "<CR>", "<Space>" },
      },
      on_close = function()
        print("Menu Closed!")
      end,
      on_submit = function(item)
        vim.cmd(":Neotree filesystem float dir=" .. item.text)
        -- print("Menu Submitted: ", item.text)
      end,
    })

  -- mount the component
  menu:mount()
end

function sort.layout()
  local Popup = require("nui.popup")
  local Layout = require("nui.layout")

  local popup_dn, popup_up = Popup({
    enter = true,
    border = "single",
  }), Popup({
    border = "double",
  })

  local layout = Layout(
    {
      position = "50%",
      size = {
        width = 80,
        height = "60%",
      },
    },
    Layout.Box({
      Layout.Box(popup_up, { size = "20%" }),
      Layout.Box(popup_dn, { size = "80%" }),
    }, { dir = "col" })
  )


  local buffer_list = buffer.enumerate_and_sort()
  popup_dn:map("n", {"r","b"}, function()
    vim.api.nvim_buf_set_lines(popup_up.bufnr, 0, -1, false, buffer_list)
  end, {})

  popup_up:map("n", {"r","b"}, function()
    vim.api.nvim_buf_set_lines(popup_dn.bufnr, 0, -1, false, buffer_list)
  end, {})

  layout:mount()
end
return sort

