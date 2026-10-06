-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Kiểm tra chính tả Anh + Việt (LazyVim tự bật spell cho markdown/text/gitcommit; bật tay: <leader>us)
vim.opt.spelllang = { "en", "vi" }
vim.opt.spelloptions:append("camel")

-- Clipboard: tránh lỗi "xclip: target STRING not available" khi clipboard trống/chứa ảnh
if vim.g.vscode then
  -- trong VS Code: dùng clipboard của VS Code (do vscode-neovim cung cấp)
  vim.g.clipboard = vim.g.vscode_clipboard
elseif vim.fn.executable("xclip") == 1 and vim.env.DISPLAY then
  -- terminal: dùng xclip nhưng nuốt stderr
  vim.g.clipboard = {
    name = "xclip-quiet",
    copy = {
      ["+"] = { "sh", "-c", "xclip -quiet -i -selection clipboard 2>/dev/null" },
      ["*"] = { "sh", "-c", "xclip -quiet -i -selection primary 2>/dev/null" },
    },
    paste = {
      ["+"] = { "sh", "-c", "xclip -o -selection clipboard 2>/dev/null || true" },
      ["*"] = { "sh", "-c", "xclip -o -selection primary 2>/dev/null || true" },
    },
    cache_enabled = 1,
  }
end

-- VS Code: hiện tên mode (NORMAL / INSERT / VISUAL ...) trên status bar.
-- vscode-neovim tự đẩy nội dung 'statusline' của Neovim sang status bar VS Code.
if vim.g.vscode then
  local names = {
    n = "NORMAL", no = "O-PENDING", nov = "O-PENDING", noV = "O-PENDING", ["no\22"] = "O-PENDING",
    niI = "NORMAL", niR = "NORMAL", niV = "NORMAL", nt = "NORMAL", ntT = "NORMAL",
    v = "VISUAL", vs = "VISUAL", V = "V-LINE", Vs = "V-LINE", ["\22"] = "V-BLOCK", ["\22s"] = "V-BLOCK",
    s = "SELECT", S = "S-LINE", ["\19"] = "S-BLOCK",
    i = "INSERT", ic = "INSERT", ix = "INSERT",
    R = "REPLACE", Rc = "REPLACE", Rx = "REPLACE", Rv = "V-REPLACE", Rvc = "V-REPLACE", Rvx = "V-REPLACE",
    c = "COMMAND", cv = "EX", ce = "EX", r = "REPLACE", rm = "MORE", ["r?"] = "CONFIRM", ["!"] = "SHELL", t = "TERMINAL",
  }
  function _G.VscodeModeName()
    local m = vim.api.nvim_get_mode().mode
    return names[m] or names[m:sub(1, 1)] or m:upper()
  end
  vim.o.showmode = false     -- tắt "-- INSERT --" mặc định cho khỏi hiện 2 lần
  vim.o.laststatus = 2
  vim.o.statusline = "%{v:lua.VscodeModeName()}"
end
