-- Plugin bổ sung (cộng đồng hay dùng). Xoá entry nào không thích là lazy.nvim tự gỡ.
return {
  -- Git: xem lịch sử file / diff từng commit (thay Git Graph + Git History của VS Code)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: thay đổi hiện tại" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: lịch sử file này" },
      { "<leader>gL", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: lịch sử repo" },
    },
    opts = {},
  },
  -- Git: giao diện kiểu magit (stage từng hunk, commit, push, log)
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    cmd = "Neogit",
    keys = { { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" } },
    opts = { integrations = { diffview = true, snacks = true }, graph_style = "unicode" },
  },
  -- oil.nvim: sửa thư mục như sửa file text (đổi tên, xoá, tạo hàng loạt rồi :w)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<cr>", desc = "Oil: mở thư mục hiện tại" } },
    opts = {
      default_file_explorer = false, -- giữ snacks explorer làm mặc định
      view_options = { show_hidden = true },
      keymaps = { ["q"] = "actions.close", ["<C-h>"] = false, ["<C-l>"] = false },
    },
  },
  -- smart-splits: Ctrl+hjkl nhảy liền mạch giữa split của nvim và pane của zellij/tmux
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = { at_edge = "stop" },
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Sang pane trái" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Sang pane dưới" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Sang pane trên" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Sang pane phải" },
      { "<A-S-h>", function() require("smart-splits").resize_left() end, desc = "Co pane trái" },
      { "<A-S-j>", function() require("smart-splits").resize_down() end, desc = "Co pane xuống" },
      { "<A-S-k>", function() require("smart-splits").resize_up() end, desc = "Co pane lên" },
      { "<A-S-l>", function() require("smart-splits").resize_right() end, desc = "Co pane phải" },
    },
  },
  -- undotree: cây lịch sử undo, quay về trạng thái bất kỳ
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undotree" } },
    init = function() vim.g.undotree_WindowLayout = 2; vim.g.undotree_SetFocusWhenToggle = 1 end,
  },
}
