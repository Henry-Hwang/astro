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
popup_dn:map("n", "r", function()
  vim.api.nvim_buf_set_lines(popup_up.bufnr, 0, -1, false, buffer_list)
end, {})

popup_up:map("n", "r", function()
  vim.api.nvim_buf_set_lines(popup_dn.bufnr, 0, -1, false, buffer_list)
end, {})

layout:mount()
