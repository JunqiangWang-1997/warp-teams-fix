#!/bin/bash

# WARP Teams IPv6 Fix - 安装脚本
# 修复了Teams账户IPv6地址解析问题
# 作者修改版本

VERSION='3.1.6-fixed'
SCRIPT_URL='https://raw.githubusercontent.com/YOUR_USERNAME/warp-script-fixed/main/menu.sh'

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印彩色信息
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "此脚本需要root权限运行"
        echo "请使用: sudo $0"
        exit 1
    fi
}

# 下载并安装脚本
install_script() {
    info "开始下载WARP Teams IPv6修复版脚本..."
    
    # 检查curl或wget
    if command -v curl >/dev/null 2>&1; then
        DOWNLOAD_CMD="curl -fsSL"
    elif command -v wget >/dev/null 2>&1; then
        DOWNLOAD_CMD="wget -qO-"
    else
        error "未找到curl或wget，请先安装"
        exit 1
    fi
    
    # 创建目录
    mkdir -p /etc/wireguard/
    
    # 下载脚本
    if $DOWNLOAD_CMD "$SCRIPT_URL" > /etc/wireguard/menu.sh; then
        chmod +x /etc/wireguard/menu.sh
        ln -sf /etc/wireguard/menu.sh /usr/bin/warp
        info "脚本下载成功！"
        info "版本: $VERSION"
        info "修复内容: Teams账户IPv6地址解析问题"
    else
        error "脚本下载失败，请检查网络连接"
        exit 1
    fi
}

# 显示使用说明
show_usage() {
    echo ""
    info "=== WARP Teams IPv6修复版 ==="
    echo ""
    echo "修复内容："
    echo "  1. 修复Teams账户IPv6地址格式解析问题"
    echo "  2. 增强IPv6地址验证逻辑"
    echo "  3. 支持带方括号和端口号的IPv6地址清理"
    echo ""
    echo "使用方法："
    echo "  warp              # 显示菜单"
    echo "  warp a            # 更换账户（支持Teams）"
    echo "  warp h            # 显示帮助"
    echo ""
    echo "Teams登录方式："
    echo "  1. 通过URL文件"
    echo "  2. 输入组织名和邮箱验证码（推荐）"
    echo "  3. 手动输入配置信息"
    echo "  4. 使用共享Teams账户"
    echo ""
    warning "注意：请确保您的组织名和邮箱地址正确"
}

# 主函数
main() {
    clear
    echo "========================================"
    echo " WARP Teams IPv6修复版 - 安装程序"
    echo " 版本: $VERSION"
    echo "========================================"
    echo ""
    
    check_root
    install_script
    show_usage
    
    echo ""
    info "安装完成！现在可以运行 'warp' 命令开始使用"
    echo ""
    
    # 询问是否立即运行
    read -p "是否立即运行WARP脚本？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        /usr/bin/warp
    fi
}

# 执行主函数
main "$@"
