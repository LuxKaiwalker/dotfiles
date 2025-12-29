-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Exit insert mode by mashing j and k
vim.keymap.set('i', 'jk', '<Esc>', { remap = false })
vim.keymap.set('i', 'kj', '<Esc>', { remap = false })

-- Adjust the timeout (default is 1000ms, which is too slow)
-- 300ms is the "sweet spot" for most people
vim.opt.timeoutlen = 300


-- Make Neovim transparent
vim.schedule(function()
  local groups = {
    "Normal",
    "NormalFloat",
    "SignColumn",
    "EndOfBuffer",
    "LineNr",
    "CursorLineNr",
    "FloatBorder",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end)
