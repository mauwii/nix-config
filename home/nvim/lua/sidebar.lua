-- sidebar like in VS Code: nvim-tree on top, the commits of the current branch below
local api = require("nvim-tree.api")

local M = {}
local ns = vim.api.nvim_create_namespace("sidebar")
local sidebar_filetypes = { NvimTree = true, gitcommits = true }
local buf

-- the commits window of the current tab
local function find_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
end

local function set_lines(lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, line in ipairs(lines) do
    local hash = line:match("^%x+ ")
    if hash then
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { end_col = #hash - 1, hl_group = "Identifier" })
    end
  end
end

function M.refresh()
  if not buf or #vim.fn.win_findbuf(buf) == 0 then
    return
  end
  vim.system({ "git", "log", "-n", "50", "--format=%h %s" }, { text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        set_lines(vim.split(result.stdout, "\n", { trimempty = true }))
      else
        set_lines({ (result.stderr:gsub("^fatal: ", ""):match("[^\n]*")) })
      end
    end)
  end)
end

local function show_commit()
  local hash = vim.api.nvim_get_current_line():match("^%x+ ")
  if hash then
    vim.cmd("DiffviewOpen " .. vim.trim(hash) .. "^!")
  end
end

local function create_buf()
  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "gitcommits"
  vim.bo[buf].modifiable = false
  vim.keymap.set("n", "<CR>", show_commit, { buffer = buf, desc = "Show commit" })
  vim.keymap.set("n", "<2-LeftMouse>", show_commit, { buffer = buf, desc = "Show commit" })
  vim.keymap.set("n", "R", M.refresh, { buffer = buf, desc = "Refresh commits" })
  vim.keymap.set("n", "q", api.tree.close, { buffer = buf, desc = "Close sidebar" })
  vim.api.nvim_create_autocmd("BufEnter", { buffer = buf, callback = M.refresh })
end

local function open()
  local tree_win = api.tree.winid()
  if not tree_win or find_win() then
    return
  end
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    create_buf()
  end
  local win = vim.api.nvim_open_win(buf, false, {
    split = "below",
    win = tree_win,
    height = math.floor(vim.o.lines / 3),
    style = "minimal",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false
  vim.wo[win].winfixwidth = true
  vim.wo[win].winbar = " COMMITS"
  -- the sidebar colors of the tree
  vim.wo[win].winhighlight = vim.wo[tree_win].winhighlight
  M.refresh()
end

local function close()
  local win = find_win()
  if win then
    -- fails if it is the last window, then :q closes it
    pcall(vim.api.nvim_win_close, win, true)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("sidebar", {})

  api.events.subscribe(api.events.Event.TreeOpen, function()
    vim.schedule(open)
  end)

  -- covers every way to close the tree: q, :q, <C-b>, ...
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function()
      vim.schedule(function()
        if not api.tree.is_visible() then
          close()
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "FocusGained", "DirChanged", "ShellCmdPost" }, {
    group = group,
    callback = M.refresh,
  })

  -- open with a directory or without a file, like a folder in VS Code
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function(data)
      local directory = vim.fn.isdirectory(data.file) == 1
      -- line2byte is -1 for an empty buffer, so nothing was read from stdin
      local empty = data.file == "" and vim.fn.line2byte("$") == -1
      if directory then
        vim.cmd.enew()
        vim.cmd.bwipeout(data.buf)
        vim.cmd.cd(data.file)
      end
      if directory or empty then
        api.tree.open()
      end
    end,
  })

  -- close the sidebar with the last editor window, so :q quits Neovim
  vim.api.nvim_create_autocmd("QuitPre", {
    group = group,
    callback = function()
      if sidebar_filetypes[vim.bo.filetype] then
        return
      end
      local editors = vim.tbl_filter(function(win)
        local filetype = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
        return vim.api.nvim_win_get_config(win).relative == "" and not sidebar_filetypes[filetype]
      end, vim.api.nvim_tabpage_list_wins(0))
      if #editors == 1 then
        api.tree.close()
        close()
      end
    end,
  })
end

return M
