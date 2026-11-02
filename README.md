# Dotfiles: Ghostty + zsh + Neovim cho macOS và Ubuntu

Một lệnh cài là có cùng một terminal trên Mac và Ubuntu: Ghostty (TokyoNight, Maple Mono), zsh + powerlevel10k, Neovim (LazyVim), zellij và các tool dòng lệnh hiện đại.

![zellij -l dev: LazyVim bên trái, shell bên phải](docs/images/zellij.png)

## Cài đặt

```bash
git clone https://github.com/DucLong06/iTerm2.git ~/dotfiles && ~/dotfiles/install.sh
```

`install.sh` tự nhận ra macOS hay Linux rồi chạy `mac/install.sh` hoặc `linux/install.sh`.

- **macOS:** dùng Homebrew (tự cài nếu chưa có). Máy sẽ hỏi mật khẩu khi cài Homebrew và XPipe.
- **Ubuntu:** hỏi có dùng proxy không (Enter = không), cần `sudo`. Cài xong thì khởi động lại máy và chạy thêm một lần `~/dotfiles/install.sh --skip-apt`.

Sau đó mở **Ghostty**. Chạy lại bao nhiêu lần cũng được: file nào bị thay đều có bản backup `*.bak-<ngày>` bên cạnh.

| Muốn | Lệnh |
|---|---|
| Cập nhật | `cd ~/dotfiles && git pull && ./install.sh` |
| Chỉ cài lại config | `./install.sh --only configs` |
| Xem các bước | `./install.sh --list-steps` |

## Trông như thế nào

**Prompt + `lt`** (eza dạng cây, có icon và trạng thái git)

![prompt](docs/images/prompt.png)

**fzf-tab:** gõ `cd ` rồi bấm Tab, có khung xem trước

![fzf-tab](docs/images/fzf-tab.png)

**Config Ghostty** (`cat` = bat, có tô màu)

![ghostty config](docs/images/ghostty-config.png)

**`gd`** (git diff qua delta, hai cột)

![delta](docs/images/delta.png)

**`lazygit`**

![lazygit](docs/images/lazygit.png)

**`nvim`** (LazyVim)

![nvim](docs/images/nvim.png)

## Ubuntu: Ghostty chạy trên GPU

Trên Ubuntu, Ghostty được build từ source thay vì cài bằng snap. Bản snap mang theo Mesa riêng nên không nạp được driver NVIDIA, phải vẽ bằng CPU (llvmpipe). Bản build native dùng driver của hệ thống nên vẽ bằng GPU thật.

![ghostty-gpu-check: Ghostty vẽ bằng GPU NVIDIA, 0 luồng llvmpipe](docs/images/ghostty-gpu-check.png)

Đo trên GTX 1070 Ti, driver 580, X11:

| | Snap (Ghostty 1.4) | Build native (Ghostty 1.3.1) |
|---|---|---|
| Vẽ bằng | llvmpipe (CPU), 12 luồng | NVIDIA (`libEGL_nvidia`) |
| CPU khi không gõ gì | ~766% (7–8 nhân) | ~0–3% |
| Có trong `nvidia-smi` | không | có, ~25–45MiB VRAM |

Kiểm tra trên máy của bạn bằng `ghostty-gpu-check`. Dòng cuối phải là `✔ Ghostty đang vẽ bằng GPU`.

- **Chọn GPU:** máy chỉ có một GPU (NVIDIA, AMD hay Intel) thì Ghostty dùng luôn GPU đó. Laptop có cả iGPU và NVIDIA thì launcher `~/.local/bin/ghostty` bật PRIME offload để dùng card NVIDIA.
- **Vì sao là 1.3.1:** Ghostty 1.4 cần libadwaita ≥ 1.7, còn Ubuntu 24.04 chỉ có 1.5. Bản build nằm ở `~/.local/opt/ghostty`.
- **Vẫn báo vẽ bằng CPU:** gỡ snap bằng `sudo snap remove ghostty`, rồi chạy `./install.sh --only ghostty,default-terminal`.
- **macOS** không gặp vấn đề này: Ghostty luôn vẽ bằng Metal (GPU). Shader con trỏ được đặt `custom-shader-animation = true` để chỉ chạy khi cửa sổ đang focus, đỡ tốn pin.

## Có gì trong bộ cài

| Nhóm | Gồm |
|---|---|
| Terminal | Ghostty: TokyoNight Night, Maple Mono NF, nền trong suốt, con trỏ `cursor_warp`. Mac: Option trái = Alt, ``Cmd+` `` thả terminal xuống |
| Shell | zsh + oh-my-zsh + powerlevel10k, autosuggestions, syntax-highlighting, fzf-tab, you-should-use |
| Editor | Neovim + LazyVim (plugin ghim theo `lazy-lock.json`) |
| Chia màn hình | zellij (thanh `zjstatus`, `Ctrl+hjkl` chuyển giữa nvim và pane), tmux |
| Tool | eza, bat, zoxide, atuin, yazi, fzf, ripgrep, fd, lazygit, delta, lazydocker, glow, tldr, fastfetch |
| Runtime | nvm + Node LTS, uv, Go |
| SSH | gssh (ssh mang theo gợi ý + tô màu sang máy remote), XPipe |
| Riêng Ubuntu | Ghostty build từ source, vẽ bằng GPU (`ghostty-gpu-check` để kiểm tra), là terminal mặc định (Ctrl+Alt+T, chuột phải trong Nautilus), tự chuyển bộ gõ trong Ghostty, proxy tuỳ chọn, cấu hình VS Code |

## Lệnh hay dùng

| Lệnh / phím | Làm gì |
|---|---|
| `ll`, `la`, `lt` | Liệt kê file (eza) |
| `z <tên>` | Nhảy tới thư mục hay dùng |
| `Ctrl+R` | Tìm lịch sử lệnh (atuin) |
| `y` | Duyệt file bằng yazi, thoát thì `cd` theo |
| `gd`, `lazygit` | Xem diff, quản lý git |
| `zellij -l dev` | nvim + shell + git trong một cửa sổ |
| `Cmd+Shift+,` | Nạp lại config Ghostty (Ubuntu: `Ctrl+Shift+,`) |

## Tuỳ chỉnh

- Cài đặt riêng của từng máy (alias, đường dẫn SDK…) để trong `~/.zsh_local`. File này không nằm trong repo.
- Đổi theme: chạy `ghostty +list-themes` trong Ghostty để xem thử, rồi sửa dòng `theme` trong `mac/ghostty/config` hoặc `linux/ghostty/config`.
- Đổi kiểu prompt: `p10k configure`.
- XPipe: Settings → Terminal → Ghostty; Settings → Sync → trỏ tới một repo git **private** để đồng bộ host giữa các máy.

## Cấu trúc repo

```
install.sh          chọn mac/ hoặc linux/
mac/                install.sh, zsh/.zshrc, ghostty/config
linux/              install.sh, zsh/, ghostty/, nvim/, zellij/, tmux/, vscode/ (nvim, zellij, tmux, p10k dùng chung cho Mac)
linux/bin/          ghostty (launcher chọn GPU), ghostty-gpu-check, ghostty-ime-watch
docs/images/        ảnh trong README; tạo lại bằng: for t in docs/tapes/[!_]*.tape; do vhs "$t"; done
                    (ghostty-gpu-check.png là ảnh chụp cửa sổ Ghostty thật trên Ubuntu)
docs/legacy-iterm2.md   hướng dẫn iTerm2 cũ
```
