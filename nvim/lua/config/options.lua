-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.termguicolors = true

-- Use the system clipboard over SSH / in containers via OSC 52 (works in WSL and DevPod)
if vim.env.SSH_TTY or vim.env.DEVPOD or vim.env.REMOTE_CONTAINERS then
  vim.g.clipboard = "osc52"
end
