-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.termguicolors = true

-- Over SSH / in containers (DevPod), copy to the host clipboard via OSC 52.
-- Paste is served from the last copy instead: Windows Terminal can't answer
-- OSC 52 reads, so "+p would hang. Paste from Windows with Ctrl+Shift+V.
-- (Plain WSL needs none of this: nvim uses clip.exe/powershell there.)
if vim.env.SSH_TTY or vim.env.DEVPOD or vim.env.REMOTE_CONTAINERS then
  local osc52 = require("vim.ui.clipboard.osc52")
  local last = { lines = { "" }, regtype = "v" }
  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      last = { lines = lines, regtype = regtype }
      send(lines)
    end
  end
  local function paste()
    return { last.lines, last.regtype }
  end
  vim.g.clipboard = {
    name = "OSC 52 (copy only)",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
