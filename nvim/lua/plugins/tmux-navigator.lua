-- Ctrl+h/j/k/l moves seamlessly between nvim splits and tmux panes.
-- Needs the matching tmux plugin (see tmux/tmux.conf).
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Go to Left Window/Pane" },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Go to Lower Window/Pane" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Go to Upper Window/Pane" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Go to Right Window/Pane" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Go to Previous Window/Pane" },
  },
}
