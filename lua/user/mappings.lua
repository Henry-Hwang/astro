-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
local sort = require "user.plugins.sort.sort"
return {
  -- first key is the mode
  n = {
    -- mappings seen under group name "Buffer"
    ["<leader>b" ] = { name = "Buffers" },
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {function() require("astronvim.utils.status").heirline.buffer_picker(function(bufnr) require("astronvim.utils.buffer").close(bufnr) end) end, desc = "Pick to close",},
    ["<leader>r" ] = { ":%s/<C-r><C-w>/<C-r><C-w>/gc", desc = "Replace word" },
    ["ff"        ] = { "/<C-r><C-w>", desc = "Search word"},
    ["<C-s>"     ] = { ":let @a='' <bar> g/<C-r><C-w>/yank A", desc = "Handle lines with [PATTEN] " },
    ["<C-e>"     ] = { "<cmd>Neotree filesystem dir=%:h float<cr>", desc = "Path to file" },  -- change description but the same command
    ["<Leader>yy"] = {":<C-u>execute 'normal! ' . v:count1 . 'yy' | let @+ = @0<cr>", desc = "Copy to system clipboard" },
    ["<Leader>p" ] = { ":put +<cr>", desc = "Paste from register(+)" },
    ["<Leader>W" ] = { ":wa!<cr>", desc = "Write all force" },
    ["<Leader>C" ] = { ":bd!<cr>", desc = "Force Remove buffer" },
    ["<C-a>"     ] = {function () sort.list_buf_popup() end, desc = "List buffer sorted"},
    ["<leader>q" ] = {function () sort.toggle_quickfix() end, desc = "Toggle Quickfix"},
    ["<leader>tf"] = { "<cmd>ToggleTerm dir=%:p:h direction=float<cr>", desc = "ToggleTerm float" },
    ["<leader>tv"] = { "<cmd>ToggleTerm size=80 dir=%:p:h direction=vertical<cr>", desc = "ToggleTerm vertical split" },
    ["<leader>," ] = {name = "Search",
      p = {function () sort.menu_default_path() end, "Most Use Path"},
      e = {function () sort.explore(vim.fn.expand("%:h")) end, "Explore Path"},
      t = {function () sort.trim_buffer() end, "Trim buffer"},
	    u = {function () sort.nvim_userdir() end, "Neovim Directory"},
      g = {function () sort.grep_global_quickfix({vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")}) end, "Find WORD in path"},
      G = {function () sort.grep_quickfix_popup(vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")) end, "Find WORD in path - Popup"},
      r = {function () sort.regex_buf_quickfix({vim.fn.input("\nPeter\\&Bob, Peter\\|Bob\n Regex: ")}) end, "Regex Buffer"},
      f = {function () sort.find_word_quickfix(vim.fn.expand("<cword>")) end, "Find WORD in buffer"},
      F = {function () sort.find_word_quickfix_popup(vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")) end, "Find WORD - Popup"},
      m = {function () sort.find_files_quickfix({vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")}) end, "Find Files"},
      M = {function () sort.find_files_quickfix_popup(vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")) end, "Find Files - Popup"},
      k = {function () sort.regex_keep_buffer(vim.fn.input("Regex: ")) end, "Regex and Keep"},
      d = {function () sort.regex_remove_buffer(vim.fn.input("Regex: ")) end, "Regex and Remove"},
      s = {function () sort.save_buffer_popup(vim.fn.expand("<cword>"), vim.fn.expand("%:p")) end, "Save Buffer - Popup"},
    },
    ["<leader>m" ] = {name = "Mark",
      a = { ":ma a <cr>", desc = "Mark A" },
      b = { ":ma b <cr>", desc = "Mark A" },
      c = { ":ma c <cr>", desc = "Mark A" },
      d = { ":ma d <cr>", desc = "Mark A" },
      e = { ":ma e <cr>", desc = "Mark A" },
      f = { ":ma f <cr>", desc = "Mark A" },
    },
    -- ["<Leader>,"] = { "<cmd>tcd %:h<cr>", desc = "Tcd to current directly" },
    -- ["<Leader>y"] = { "\"+y", desc = "Copy to system clipboard(+)"},
    -- ["<leader>.p" ] = { ":!python %<cr>", desc = "Build Python" },
    ["<leader>." ] = {name = "AutoRunner",
      r = { "<cmd>AutoRunnerRun<cr>", "Run the command" },
      t = { "<cmd>AutoRunnerToggle<cr>", "Toggle output window" },
      e = { "<cmd>AutoRunnerEditFile<cr>", "Edit build file (if available in runtime directory)" },
      a = { "<cmd>AutoRunnerAddCommand<cr>", "Add/change command" },
      c = { "<cmd>AutoRunnerClearCommand<cr>", "Clear command" },
      C = { "<cmd>AutoRunnerClearAll<cr>", "Clear all (command and buffers)" },
      p = { "<cmd>AutoRunnerPrintCommand<cr>", "Print command" },
    },
    ["<leader>;;"] = {
      function ()
        local pattern, path = vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")
      end,
      desc = "Test block"
    },
  },
  
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
    ["<C-]>"] = { "<C-\\><C-n>", desc = "Terminal normal mode" },
    ["<esc><esc>"] = { "<C-\\><C-n>:q<cr>", desc = "Terminal quit" },
  },
}
