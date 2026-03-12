#!/bin/bash
# =======================================================
# 一键部署与管理脚本: goff
# 用法: ./goff.sh {install|start|stop|restart|uninstall|status|log}
# =======================================================

# ---- 用户自定义配置 ----
NAME="goff"
DOWNLOAD_URL="https://release-assets.githubusercontent.com/github-production-release-asset/1166343731/095e2faa-1644-4771-a0c8-1ae88eeb2e2a?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-12T01:35:13Z&rscd=attachment;+filename=goway_1.0.8a_debian11&rsct=application/octet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-12T00:34:57Z&ske=2026-03-12T01:35:13Z&sks=b&skv=2018-11-09&sig=CNR+QcjctvDDwhkRbuLl6rdAVmd/f+0cUeXwQJJPvLk=&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MzI3NjcwOSwibmJmIjoxNzczMjc2NDA5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.G5k2YXDB0h4qsQh4OLAHE5QiZufF8zgUAlzvQZUEpSA&response-content-disposition=attachment; filename=goway_1.0.8a_debian11&response-content-type=application/octet-stream"
ARGS="/root/goff"

# ---- 自动生成的路径（全部以程序名称命名）----
INSTALL_DIR="/root/${NAME}"
BIN_PATH="${INSTALL_DIR}/${NAME}"
SERVICE_NAME="${NAME}"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# ---- 辅助函数 ----
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "错误: 请使用 root 权限运行此脚本 (sudo $0 $1)"
        exit 1
    fi
}

# ---- install: 下载 + 重命名 + 注册服务 + 启动 ----
do_install() {
    check_root
    echo "========================================="
    echo " 开始安装 ${NAME}"
    echo "========================================="

    # 创建安装目录
    mkdir -p "${INSTALL_DIR}"

    # 下载程序（无论原始文件名是什么，都保存为程序名称）
    echo "[1/4] 正在下载程序..."
    wget -q --show-progress -O "${BIN_PATH}" "${DOWNLOAD_URL}"
    if [ $? -ne 0 ]; then
        echo "下载失败，请检查URL或网络连接！"
        exit 1
    fi

    # 赋予执行权限
    echo "[2/4] 赋予执行权限..."
    chmod +x "${BIN_PATH}"

    # 创建 systemd 服务
    echo "[3/4] 配置 systemd 自启动服务..."
    cat > "${SERVICE_FILE}" << SVCEOF
[Unit]
Description=${NAME} Service
After=network.target

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}
ExecStart=${BIN_PATH} ${ARGS}
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
SVCEOF

    # 启动服务
    echo "[4/4] 启动服务..."
    systemctl daemon-reload
    systemctl enable ${SERVICE_NAME}.service
    systemctl start ${SERVICE_NAME}.service

    echo ""
    echo "========================================="
    echo " ${NAME} 安装完成并已启动！"
    echo ""
    echo " 安装目录: ${INSTALL_DIR}"
    echo " 程序路径: ${BIN_PATH}"
    echo " 服务名称: ${SERVICE_NAME}"
    echo ""
    echo " 管理命令:"
    echo "   $0 start     启动"
    echo "   $0 stop      停止"
    echo "   $0 restart   重启"
    echo "   $0 status    状态"
    echo "   $0 log       日志"
    echo "   $0 uninstall 卸载"
    echo "========================================="
}

# ---- start ----
do_start() {
    check_root
    systemctl start ${SERVICE_NAME}.service
    echo "${NAME} 已启动。"
}

# ---- stop ----
do_stop() {
    check_root
    systemctl stop ${SERVICE_NAME}.service
    echo "${NAME} 已停止。"
}

# ---- restart ----
do_restart() {
    check_root
    systemctl restart ${SERVICE_NAME}.service
    echo "${NAME} 已重启。"
}

# ---- uninstall: 停止+禁用+删除服务+删除文件 ----
do_uninstall() {
    check_root
    echo "正在卸载 ${NAME}..."
    systemctl stop ${SERVICE_NAME}.service 2>/dev/null
    systemctl disable ${SERVICE_NAME}.service 2>/dev/null
    rm -f "${SERVICE_FILE}"
    systemctl daemon-reload
    rm -rf "${INSTALL_DIR}"
    echo "${NAME} 已完全卸载（已删除 ${INSTALL_DIR}）。"
}

# ---- status ----
do_status() {
    systemctl status ${SERVICE_NAME}.service
}

# ---- log ----
do_log() {
    journalctl -u ${SERVICE_NAME}.service -f
}

# ---- 命令分发 ----
case "$1" in
    install)   do_install ;;
    start)     do_start ;;
    stop)      do_stop ;;
    restart)   do_restart ;;
    uninstall) do_uninstall ;;
    status)    do_status ;;
    log)       do_log ;;
    *)
        echo "========================================="
        echo " goff 管理脚本"
        echo "========================================="
        echo ""
        echo "用法: $0 {命令}"
        echo ""
        echo "可用命令:"
        echo "  install    下载安装程序并配置自启动"
        echo "  start      启动服务"
        echo "  stop       停止服务"
        echo "  restart    重启服务"
        echo "  uninstall  完全卸载（停止+删除文件+删除服务）"
        echo "  status     查看服务运行状态"
        echo "  log        实时查看运行日志"
        echo ""
        exit 1
        ;;
esac