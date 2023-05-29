-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
local sort = require "user.plugins.sort.sort"
local system = vim.loop.os_uname().sysname
local userdir = vim.fn.getenv("HOME") .. "/.config/nvim/lua/user"
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(function(bufnr) require("astronvim.utils.buffer").close(bufnr) end)
      end,
      desc = "Pick to close",
    },
    -- tables with the `name` key will be registered with which-key if it's installed
    ["<leader>b"] = { name = "Buffers" },
    ["<leader>r"] = { ":%s/<C-r><C-w>/<C-r><C-w>/gc", desc = "Replace word" },
    ["ff"] = { "/<C-r><C-w>", desc = "Search word"},
    ["<C-s>"] = { ":let @a='' <bar> g/<C-r><C-w>/yank A", desc = "Handle lines with [PATTEN] " },
    -- ["<C-a>"] = { "<cmd>Neotree buffers position=float<cr>", desc = "Show buffers" },  -- change description but the same command
    ["<C-f>"] = { "<cmd>Telescope find_files<cr>", desc = "Find files" },  -- change description but the same command
    ["<C-e>"] = { "<cmd>Neotree filesystem dir=%:h float<cr>", desc = "Path to file" },  -- change description but the same command
    -- ["<Leader>y"] = { "\"+y", desc = "Copy to system clipboard(+)"},
    ["<Leader>yy"] = {":<C-u>execute 'normal! ' . v:count1 . 'yy' | let @+ = @0<cr>", desc = "Copy to system clipboard" },
    ["<Leader>p"] = { ":put +<cr>", desc = "Paste from register(+)" },
    ["<Leader>W"] = { ":wa!<cr>", desc = "Write all force" },
    -- ["<Leader>,"] = { "<cmd>tcd %:h<cr>", desc = "Tcd to current directly" },
    ["<C-a>"] = {
      function ()
        sort.popup_buffers()
      end,
      desc = "List buffer sorted"
    },
    ["<leader>,g"] = {
      function ()
        local pattern = vim.fn.expand("<cword>")
        local path = vim.fn.expand("%:h")
        sort.grep_path_quickfix(pattern, path)
      end,
      desc = "Grep WORD in path"
    },
    ["<leader>,l"] = {
      function ()
        local pattern = vim.fn.expand("<cword>")
        sort.find_buf_quickfix(pattern)
      end,
      desc = "Find WORD in buffer"
    },
    ["<leader>,r"] = {
      function ()
        local pattern = vim.fn.input("regular expression: ")
        sort.regex_buf_quickfix(pattern)
      end,
      desc = "Regex patten in buffer"
    },
    ["<leader>,f"] = {
      function ()
        -- local pattern = vim.fn.expand("<cword>")
        local path = vim.fn.expand("%:h")
        sort.search_path_files(path, "pattern")
      end,
      desc = "Search files in current path"
    },
    ["<leader>,s"] = {
      function ()
        local pattern = vim.fn.expand("<cword>")
        local path = vim.fn.expand("%:h")
        sort.popup_search(pattern, path)
      end,
      desc = "Search WORD on popup"
    },
    ["<leader>,k"] = {
      function ()
        sort.trim_buffer()
      end,
      desc = "Trim buffer"
    },
	  ["<Leader>,u"] = { 
	    function ()
		    if system == "Windows_NT" then
			    userdir = vim.fn.getenv("LOCALAPPDATA") .. "/nvim/lua/user"
		    end
		    vim.cmd(":Neotree filesystem position=float dir=" .. userdir)
	    end,
	    desc = "Explore user config directory"
	  },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
    ["<leader>dr"] = {
      function()
        local word = vim.fn.expand "<cword>"
        local rp = vim.fn.input "Replace with: "
        vim.cmd("%s/" .. word .. "/" .. rp .. "/g")
      end,
    },
    -- sort keep, delete
    ["<leader>;k"] = {
      function ()
      local pattern = vim.fn.input("Pattern: ")
      sort.regex_keep_match(pattern)
      end,
      desc = "Sort keep lines"
    },
    ["<leader>;d"] = {
      function ()
      local pattern = vim.fn.input("regular expression: ")
      sort.regex_keep_match(pattern)
      end,
      desc = "Sort delete lines"
    },
    ["<leader>;;"] = {
      function ()
        local pattern = vim.fn.expand("<cword>")
        local path = vim.fn.expand("%:h")
        -- local pattern = vim.fn.input("regular expression: ")
        -- sort.populateQuickfix(pattern)
        -- sort.trim_buffer()
        -- sort.regex_buf_quickfix(pattern)
        -- sort.fzf_quickfix()
        sort.popup_search(pattern, path)
      end,
      desc = "Sort trim buffer"
    },
    ["<leader>;o"] = {
      function ()
        print("Test ...")
      end,
      desc = "Sort Test"
    },
  },
  
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
    ["<C-]>"] = { "<C-\\><C-n>", desc = "Terminal normal mode" },
    ["<esc><esc>"] = { "<C-\\><C-n>:q<cr>", desc = "Terminal quit" },
  },
}
