-- nvim-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("vscode").setup({})
vim.cmd.colorscheme("vscode")

require("nvim-tree").setup({
  -- the sidebar module opens directories as a sidebar instead of in the current window
  hijack_directories = { enable = false },
  view = { width = 35 },
  renderer = { group_empty = true },
  update_focused_file = { enable = true },
  filters = { git_ignored = false, custom = { "^\\.git$" } },
})

-- close a buffer but keep its windows, otherwise only the sidebar could be left
local function delete_buffer(buf)
  if buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  if vim.bo[buf].modified then
    vim.notify("No write since last change", vim.log.levels.WARN)
    return
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      vim.cmd.bprevious()
      if vim.api.nvim_get_current_buf() == buf then
        vim.cmd.enew()
      end
    end)
  end
  vim.cmd("bdelete " .. buf)
end

require("bufferline").setup({
  options = {
    close_command = delete_buffer,
    right_mouse_command = delete_buffer,
    offsets = {
      { filetype = "NvimTree", text = "EXPLORER", text_align = "left", separator = true },
    },
  },
})

require("lualine").setup({
  options = { theme = "vscode", globalstatus = true },
  extensions = { "nvim-tree" },
})

require("gitsigns").setup()

local close_diffview = { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } }
require("diffview").setup({
  keymaps = {
    view = { close_diffview },
    file_panel = { close_diffview },
    file_history_panel = { close_diffview },
  },
})

vim.keymap.set("n", "<C-b>", function()
  require("nvim-tree.api").tree.toggle({ focus = false })
end, { desc = "Toggle sidebar" })
vim.keymap.set("n", "<C-x>", function()
  delete_buffer(0)
end, { desc = "Close buffer" })
vim.keymap.set("n", "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>", { desc = "File history" })

require("sidebar").setup()
