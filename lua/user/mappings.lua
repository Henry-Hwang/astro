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
    ["<leader>," ] = { name = "Search" },
    ["<leader>,p"] = {function () sort.menu_default_path() end, desc = "Most Use Path"},
    ["<leader>,e"] = {function () sort.explore(vim.fn.expand("%:h")) end, desc = "Explore Path"},
    ["<leader>,k"] = {function () sort.trim_buffer() end, desc = "Trim buffer"},
	  ["<Leader>,u"] = {function () sort.nvim_userdir() end, desc = "Neovim Directory"},
    ["<leader>,g"] = {function () sort.grep_path_quickfix(vim.fn.expand("<cword>"), vim.fn.expand("%:h")) end, desc = "Find WORD in path"},
    ["<leader>,r"] = {function () sort.regex_buf_quickfix({vim.fn.input("\nPeter\\&Bob, Peter\\|Bob\n Regex: ")}) end, desc = "Regex Buffer"},
    ["<leader>,f"] = {function () sort.find_word_quickfix(vim.fn.expand("<cword>")) end, desc = "Find WORD in buffer"},
    ["<leader>,F"] = {function () sort.find_word_quickfix_popup(vim.fn.expand("<cword>"), vim.fn.expand("%:h")) end, desc = "Find WORD - Popup"},
    ["<leader>,m"] = {function () sort.find_files_quickfix(vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")) end, desc = "Find Files"},
    ["<leader>,M"] = {function () sort.find_files_quickfix_popup(vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")) end, desc = "Find Files - Popup"},
    -- ["<Leader>,"] = { "<cmd>tcd %:h<cr>", desc = "Tcd to current directly" },
    -- ["<Leader>y"] = { "\"+y", desc = "Copy to system clipboard(+)"},
    ["<leader>;k"] = {function () sort.regex_keep_match(vim.fn.input("Pattern: ")) end, desc = "Sort keep lines"},
    ["<leader>;d"] = {function () sort.regex_keep_match(vim.fn.input("Regex: ")) end, desc = "Sort delete lines"},
    ["<leader>;;"] = {
      function ()
        local pattern, path = vim.fn.expand("<cword>"), vim.fn.expand("%:p:h")
        -- sort.layout()
        -- sort.find_files(pattern, path)
        -- sort.find_files_quickfix_popup(pattern, path)
        -- Define the table of strings
        -- Define the table of strings
        sort.showFileList1()
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
