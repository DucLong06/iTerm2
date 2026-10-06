-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Bộ gõ tiếng Việt (ibus Unikey): rời Insert mode thì chuyển về tiếng Anh để phím vim không bị ăn,
-- vào Insert mode thì trả lại bộ gõ đang dùng trước đó.
if vim.fn.executable("ibus") == 1 then
  local saved_im = nil
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = vim.api.nvim_create_augroup("vi_ime_switch", { clear = true }),
    callback = function()
      vim.system({ "ibus", "engine" }, { text = true }, function(r)
        local cur = vim.trim(r.stdout or "")
        if cur ~= "" and cur ~= "xkb:us::eng" then
          saved_im = cur
          vim.system({ "ibus", "engine", "xkb:us::eng" })
        end
      end)
    end,
  })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = "vi_ime_switch",
    callback = function()
      if saved_im then vim.system({ "ibus", "engine", saved_im }) end
    end,
  })
end
