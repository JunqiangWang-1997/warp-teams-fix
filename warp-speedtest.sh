#!/bin/bash

# WARP IPv4 网络测速脚本
# 测试WARP连接的网络性能

VERSION="1.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印函数
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

title() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

# 检测网络连接状态
check_network_status() {
    title "检测网络连接状态"
    
    # 检查IPv4连接
    echo -n "检查IPv4连接... "
    IPV4_TEST=$(curl -s4 --max-time 5 https://ipinfo.io/ip)
    
    if [[ -n "$IPV4_TEST" && "$IPV4_TEST" != "" ]]; then
        info "IPv4连接: ${GREEN}正常${NC} ($IPV4_TEST)"
        return 0
    else
        error "IPv4连接: ${RED}失败${NC}"
        echo "请检查网络连接"
        return 1
    fi
}

# 获取IP信息
get_ip_info() {
    title "获取IP信息"
    
    # IPv4信息
    echo -n "获取IPv4信息... "
    IPV4_INFO=$(curl -s4 --max-time 10 https://ipinfo.io/json)
    if [ $? -eq 0 ]; then
        IPV4=$(echo "$IPV4_INFO" | grep '"ip"' | cut -d'"' -f4)
        COUNTRY=$(echo "$IPV4_INFO" | grep '"country"' | cut -d'"' -f4)
        CITY=$(echo "$IPV4_INFO" | grep '"city"' | cut -d'"' -f4)
        ORG=$(echo "$IPV4_INFO" | grep '"org"' | cut -d'"' -f4)
        echo -e "${GREEN}✓${NC}"
        echo -e "  IPv4: ${BLUE}$IPV4${NC}"
        echo -e "  位置: ${BLUE}$CITY, $COUNTRY${NC}"
        echo -e "  运营商: ${BLUE}$ORG${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    echo ""
}

# HTTP下载测速
test_http_speed() {
    title "HTTP下载测速"
    
    # 测试文件列表 (文件大小: URL)
    declare -A TEST_FILES=(
        ["10MB"]="http://speedtest.tele2.net/10MB.zip"
        ["100MB"]="http://speedtest.tele2.net/100MB.zip"
        ["1GB"]="http://speedtest.tele2.net/1GB.zip"
    )
    
    for SIZE in "10MB" "100MB"; do
        echo -n "测试 $SIZE 文件下载速度... "
        
        # 使用curl测速，限制时间30秒
        SPEED_RESULT=$(curl -o /dev/null -s4 --max-time 30 -w "%{speed_download}" "${TEST_FILES[$SIZE]}")
        
        if [ $? -eq 0 ] && [ "$SPEED_RESULT" != "0.000" ]; then
            # 转换为Mbps
            SPEED_MBPS=$(echo "scale=2; $SPEED_RESULT * 8 / 1024 / 1024" | bc -l 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓${NC} ${BLUE}${SPEED_MBPS} Mbps${NC}"
            else
                # 如果bc不可用，使用awk
                SPEED_MBPS=$(awk "BEGIN {printf \"%.2f\", $SPEED_RESULT * 8 / 1024 / 1024}")
                echo -e "${GREEN}✓${NC} ${BLUE}${SPEED_MBPS} Mbps${NC}"
            fi
        else
            echo -e "${RED}✗ 测试失败${NC}"
        fi
        
        # 短暂延迟
        sleep 1
    done
    
    echo ""
}

# Ping测试
test_ping() {
    title "Ping延迟测试"
    
    # 测试目标列表
    declare -A PING_TARGETS=(
        ["Google DNS"]="8.8.8.8"
        ["Cloudflare DNS"]="1.1.1.1"
        ["腾讯DNS"]="119.29.29.29"
        ["阿里DNS"]="223.5.5.5"
    )
    
    for NAME in "Google DNS" "Cloudflare DNS" "腾讯DNS" "阿里DNS"; do
        TARGET="${PING_TARGETS[$NAME]}"
        echo -n "Ping $NAME ($TARGET)... "
        
        # 发送3个ping包
        PING_RESULT=$(ping -c 3 -W 3 "$TARGET" 2>/dev/null | tail -1)
        
        if [ $? -eq 0 ]; then
            # 提取平均延迟
            AVG_PING=$(echo "$PING_RESULT" | awk -F'/' '{print $5}' 2>/dev/null)
            if [ -n "$AVG_PING" ]; then
                echo -e "${GREEN}✓${NC} ${BLUE}${AVG_PING}ms${NC}"
            else
                echo -e "${YELLOW}? 无法解析结果${NC}"
            fi
        else
            echo -e "${RED}✗ 超时${NC}"
        fi
    done
    
    echo ""
}

# 网站连接测试
test_website_access() {
    title "网站连接测试"
    
    # 测试网站列表
    declare -A WEBSITES=(
        ["Google"]="https://www.google.com"
        ["YouTube"]="https://www.youtube.com"
        ["Netflix"]="https://www.netflix.com"
        ["ChatGPT"]="https://chat.openai.com"
        ["GitHub"]="https://github.com"
        ["百度"]="https://www.baidu.com"
    )
    
    for SITE in "Google" "YouTube" "Netflix" "ChatGPT" "GitHub" "百度"; do
        URL="${WEBSITES[$SITE]}"
        echo -n "测试 $SITE 连接... "
        
        # 测试HTTP响应时间
        RESPONSE_TIME=$(curl -o /dev/null -s4 --max-time 10 -w "%{time_total}" "$URL")
        HTTP_CODE=$(curl -o /dev/null -s4 --max-time 10 -w "%{http_code}" "$URL")
        
        if [ $? -eq 0 ] && [ "$HTTP_CODE" != "000" ]; then
            RESPONSE_MS=$(awk "BEGIN {printf \"%.0f\", $RESPONSE_TIME * 1000}")
            if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 400 ]; then
                echo -e "${GREEN}✓${NC} ${BLUE}${RESPONSE_MS}ms${NC} (HTTP $HTTP_CODE)"
            else
                echo -e "${YELLOW}⚠${NC} ${BLUE}${RESPONSE_MS}ms${NC} (HTTP $HTTP_CODE)"
            fi
        else
            echo -e "${RED}✗ 连接失败${NC}"
        fi
    done
    
    echo ""
}



# 生成测速报告
generate_report() {
    title "测速报告总结"
    
    echo -e "${PURPLE}测试时间:${NC} $(date)"
    echo -e "${PURPLE}测试版本:${NC} $VERSION"
    echo ""
    echo -e "${CYAN}建议:${NC}"
    echo "• 如果下载速度低于预期，可以尝试更换网络线路"
    echo "• 如果延迟较高，可以检查网络连接质量"
    echo "• 如果网站无法访问，可能需要检查DNS设置"
    echo ""
}

# 主函数
main() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║               WARP IPv4 网络测速工具                     ║"
    echo "║                    版本: $VERSION                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 检查必要命令
    for cmd in curl ping; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error "缺少必要命令: $cmd"
            exit 1
        fi
    done
    
    # 执行测试
    if check_network_status; then
        get_ip_info
        test_ping
        test_http_speed
        test_website_access
        generate_report
    else
        error "请检查网络连接后再进行测试"
        exit 1
    fi
}

# 脚本帮助
show_help() {
    echo "WARP IPv4 测速脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help    显示此帮助信息"
    echo "  -q, --quick   快速测试（跳过大文件下载）"
    echo ""
    echo "示例:"
    echo "  $0            # 完整测试"
    echo "  $0 -q         # 快速测试"
}

# 参数处理
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -q|--quick)
        # 快速模式，可以跳过某些耗时测试
        QUICK_MODE=1
        ;;
    "")
        # 默认完整测试
        ;;
    *)
        echo "未知选项: $1"
        echo "使用 -h 查看帮助"
        exit 1
        ;;
esac

# 执行主函数
main
