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
    -- ["<C-a>"     ] = {function () sort.list_buf_popup() end, desc = "List buffer sorted"},
    ["<C-a>"     ] = {":lua require('telescope.builtin').buffers({ sort_mru = true, ignore_current_buffer = true })<cr>", desc = "List buffer sorted"},
    ["<leader>q" ] = {function () sort.toggle_quickfix() end, desc = "Toggle Quickfix"},
    ["<leader>tf"] = { "<cmd>ToggleTerm dir=%:p:h direction=float<cr>", desc = "ToggleTerm float" },
    ["<leader>tv"] = { "<cmd>ToggleTerm size=80 dir=%:p:h direction=vertical<cr>", desc = "ToggleTerm vertical split" },
    ["<leader>," ] = {name = "Search",
      L = {function () vim.cmd([[%s/\r$// | w]]) end, "Trim ^M" },
      c = {function () sort.popup_caller({pattern=nil, path=vim.fn.expand("%:p:h"), word=true}, sort.tcd_popup) end, "Tcd to Path - Popup"},
      p = {function () sort.most_paths() end, "Most Use Path"},
      e = {function () sort.open_in_explore(vim.fn.expand("%:h")) end, "Open file location"},
      t = {function () sort.trim_buffer() end, "Trim buffer"},
	    u = {function () sort.nvim_userdir() end, "Neovim Directory"},
      g = {function () sort.find_word_top({pattern=vim.fn.expand("<cword>"), path=vim.fn.expand("%:p:h"), word=true}) end, "Find WORD -Top"},
      G = {function () sort.find_word_top({pattern=vim.fn.expand("<cword>"), path=vim.fn.expand("%:p:h"), word=false}) end, "Find WORD Ex-Top"},
      f = {function () sort.find_word({pattern=vim.fn.expand("<cword>"), path=vim.fn.expand("%:p:h"), word=true}) end, "Find WORD"},
      s = {function () sort.popup_caller({pattern=vim.fn.expand("<cword>"), path=vim.fn.expand("%:p:h"), word=true}, sort.find_word_path) end, "Find WORD - Path"},
      S = {function () sort.popup_caller({pattern=vim.fn.expand("<cword>"), path=vim.fn.expand("%:p:h"), word=false}, sort.find_word_path) end, "Find WORD - Path"},
      m = {function () sort.find_files_top({pattern=vim.fn.expand("<cword>"), path=vim.fn.expand("%:p:h"), word=true}) end, "Find Files"},
      M = {function () sort.popup_caller({pattern=vim.fn.expand("<cword>"), path=vim.fn.expand("%:p:h"), word=true}, sort.find_files_path) end, "Find Files - Popup"},
      k = {function () sort.find_and_keep(vim.fn.expand("<cword>")) end, "Find and Keep"},
      d = {function () sort.find_and_remove(vim.fn.expand("<cword>")) end, "Find and Remove"},
      w = {function () sort.popup_caller({pattern=nil, path=vim.fn.expand("%:p"), word=true}, sort.save_buffer) end, "Save Buffer - Popup"},
      h = {function () sort.open_history() end, "History open"},
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
        sort.float_information("File Information", {path})
      end,
      desc = "Test block"
    },
  },
  
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
    ["<esc>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" }
  },
}
