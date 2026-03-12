# AutoBash - 一键部署脚本生成器

一个网页端工具，帮你快速生成 Linux 服务器上的**一键部署与管理脚本**。

## 功能特点

- 🖥️ 纯前端实现，打开 HTML 即可使用，无需后端
- 📝 填写程序名称、下载地址、运行参数即可生成完整 `.sh` 脚本
- 🎨 生成的脚本带有彩色交互式菜单（gogogo.sh 风格）
- 📋 一键复制或下载生成的脚本

## 生成的脚本支持

| 命令 | 功能 |
|---|---|
| `./xxx.sh` | 打开交互式管理菜单 |
| `./xxx.sh install` | 下载安装程序并配置 systemd 自启动 |
| `./xxx.sh start` | 启动服务 |
| `./xxx.sh stop` | 停止服务 |
| `./xxx.sh restart` | 重启服务 |
| `./xxx.sh uninstall` | 完全卸载 |
| `./xxx.sh status` | 查看运行状态 |
| `./xxx.sh log` | 实时查看日志 |

## 使用方法

1. 双击打开 `autobash.html`
2. 填写程序名称、下载地址、运行参数
3. 点击「下载 .sh 文件」或「复制脚本内容」
4. 上传到服务器，`chmod +x xxx.sh && ./xxx.sh`

## License

MIT
