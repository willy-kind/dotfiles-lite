-- Personal notes picker; only active on machines where the notes repo exists
local notes = vim.fn.expand("~/repos/second-brain/1-projects/learn-nvim/")

return {
  "folke/snacks.nvim",
  keys = vim.fn.isdirectory(notes) == 1 and {
    {
      "<leader>sv",
      function()
        Snacks.picker.grep({ search = "", cwd = notes, paths = { "vim-motions.md" } })
      end,
      desc = "Search vim-motions notes",
    },
  } or {},
}
