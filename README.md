# unix_configs

用户级 Unix 开发环境配置仓库，用于在新机器上快速同步常用的 Zsh、Powerlevel10k、fzf 和 tmux 配置。

## 包含内容

```text
install.sh               根安装器：按清单调用各模块
install.modules          安装清单：一行一个启用的模块
lib/install_common.sh    各模块安装脚本共用的函数
zsh/                     Zsh 模块
zsh/install.sh           Zsh 模块安装脚本
zsh/zshrc                Zsh 主配置
zsh/zshenv               Zsh 启动环境
zsh/p10k.zsh             Powerlevel10k 主题配置
tmux/                    tmux 模块
tmux/install.sh          tmux 模块安装脚本
tmux/tmux.conf           tmux 配置
local/zsh-local.example  本机私有配置模板
```

仓库只保存可共享的配置。API Key、代理密码、机器相关路径等私有内容放在：

```bash
~/.config/unix_configs/local.zsh
```

该文件不会被提交到 Git。

## 依赖

至少需要：

- `zsh`
- `git`
- `fzf`
- `tmux`

建议同时安装：

- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- Powerlevel10k 使用的 [Nerd Font](https://www.nerdfonts.com/)

### openEuler / HCE / CentOS 系

```bash
sudo dnf install -y zsh git fzf tmux zsh-autosuggestions zsh-syntax-highlighting
```

如果发行版仓库中没有后两个 Zsh 插件，主配置会在找不到插件时自动跳过，不影响基本使用。

### macOS

```bash
brew install zsh git fzf tmux zsh-autosuggestions zsh-syntax-highlighting
```

## 安装

```bash
git clone https://github.com/Josh-Jing/unix_configs.git ~/unix_configs
cd ~/unix_configs
./install.sh
exec zsh
```

根目录 `install.sh` 不直接安装具体配置，而是读取 `install.modules`，然后按顺序调用对应模块目录下的 `install.sh`。

当前清单：

```text
zsh
tmux
```

根安装器会：

1. 解析 `install.modules` 中启用的模块；空行和 `#` 注释行会被忽略。
2. 调用 `zsh/install.sh`、`tmux/install.sh` 等模块脚本。
3. 各模块使用 `install` 命令把配置文件复制到用户目录，并设置明确权限；旧文件会被备份到 `~/.cache/unix_configs/backups/`。
4. Zsh 模块会创建私有配置文件 `~/.config/unix_configs/local.zsh`（仅首次创建，已存在则保留）。
5. Zsh 模块会在 `~/.local/share/zsh/` 下安装以下用户级插件并固定版本：
   - [fzf-tab](https://github.com/Aloxaf/fzf-tab)：`24105b1`
   - [Powerlevel10k](https://github.com/romkatv/powerlevel10k)：`604f19a`

也可以只安装指定模块：

```bash
./install.sh zsh
./install.sh zsh tmux
```

### 安装规则：使用 install 复制，不使用软链接

本仓库的配置安装统一使用 `install` 命令复制文件，例如：

```bash
install -m 644 zsh/zshrc "$HOME/.zshrc"
install -m 600 zsh/p10k.zsh "$HOME/.p10k.zsh"
```

不要把仓库内配置软链接到 `$HOME`。这样部署后的配置是独立副本：

- 删除或移动配置仓库后，用户目录中的配置仍然可用。
- 每个目标文件都有明确权限。
- 仓库更新后需要重新运行 `./install.sh`，新配置才会复制到用户目录。
- 重新安装前，脚本会自动备份用户目录中已有的同名文件。

网络受限时可以跳过 Git 插件克隆：

```bash
SKIP_PLUGIN_INSTALL=1 ./install.sh
```

临时禁用某个模块时，编辑 `install.modules`，在对应模块名前加 `#`：

```text
zsh
#tmux
```

未来增加 Vim、Emacs 等模块时，推荐添加独立目录和模块脚本：

```text
vim/install.sh
vim/vimrc
emacs/install.sh
emacs/...
```

然后在 `install.modules` 中加入 `vim` 或 `emacs`。

## 配置私有环境变量

编辑：

```bash
vim ~/.config/unix_configs/local.zsh
chmod 600 ~/.config/unix_configs/local.zsh
```

示例：

```zsh
export VOLC_AGENT_PLAN_API_KEY="your-api-key"

export http_proxy="http://username:password@127.0.0.1:7890"
export https_proxy="$http_proxy"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$http_proxy"
export no_proxy="localhost,127.0.0.1,::1"
export NO_PROXY="$no_proxy"
```

## 常用快捷键

### Zsh / fzf

- `Ctrl+R`：模糊搜索历史命令
- `Ctrl+T`：模糊选择文件
- `Alt+C`：模糊跳转目录
- `**<Tab>`：触发 fzf 补全
- 方向键 `→` 或 `End`：采纳灰色行内建议
- `Ctrl+Space`：采纳灰色行内建议

### tmux

- 前缀键：`Ctrl+\`
- 鼠标支持已开启
- 需要 tmux 3.2 或更新版本；终端需支持 256 色和真彩色。
- 使用 `xterm-256color`，补充 RGB / Tc 真彩色声明，并为新窗口设置 `COLORTERM=truecolor`。

仅更新 tmux 配置：

```bash
./install.sh tmux
# 有运行中的 tmux server 时加载配置：
tmux source-file ~/.tmux.conf
```

加载后重新连接 tmux，并在新窗口中重新启动 TUI 应用。已有窗口中的环境变量不会自动更新。

注意：真彩色配置不保证应用主题一定提供彩色底色。Pi 的 `system` 主题在无法取得终端颜色时可能取消面板底色，可在 Pi 中通过 `/settings` 选择 `dark` 主题；本仓库不管理 Pi 的 `settings.json`。

## 将 Zsh 设置为默认 Shell

确认 Zsh 路径在 `/etc/shells` 中，然后执行：

```bash
chsh -s /bin/zsh
```

重新登录后生效。

## 更新配置

```bash
cd ~/unix_configs
git pull
./install.sh
```

安装后的配置文件是仓库文件的副本，不会随 `git pull` 自动变化。更新仓库后需要重新运行：

```bash
./install.sh
```

重新安装会再次备份用户目录中已存在的配置文件。已存在的第三方插件目录不会被脚本强制切换版本，避免覆盖本地修改；如需重新安装，可先删除对应目录后再运行脚本。
