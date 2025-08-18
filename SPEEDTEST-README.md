# WARP 测速工具使用说明

本工具用于测试 WARP IPv4 网络连接的性能和稳定性。

## 文件说明

- `warp-speedtest.sh` - Linux/macOS 版本（Bash脚本）
- `warp-speedtest.ps1` - Windows 版本（PowerShell脚本）

## 功能特性

### 🔍 WARP状态检测
- 自动检测WARP是否正确开启
- 显示WARP工作状态（on/plus/off）

### 🌐 IP信息获取
- 显示当前IPv4地址
- 显示地理位置信息
- 显示网络运营商信息

### ⚡ 网络速度测试
- **下载速度测试**：使用10MB和100MB文件测试下载速度
- **延迟测试**：测试到主要DNS服务器的Ping延迟
- **网站连接测试**：测试主要网站的响应时间

### 🎬 流媒体解锁测试
- Netflix 解锁状态检测
- YouTube Premium 访问测试

## 使用方法

### Linux/macOS 使用方法

```bash
# 给脚本执行权限
chmod +x warp-speedtest.sh

# 完整测试
./warp-speedtest.sh

# 快速测试（跳过大文件下载）
./warp-speedtest.sh -q

# 查看帮助
./warp-speedtest.sh -h
```

### Windows 使用方法

```powershell
# 完整测试
.\warp-speedtest.ps1

# 快速测试
.\warp-speedtest.ps1 -Quick

# 查看帮助
.\warp-speedtest.ps1 -Help
```

**注意**：Windows用户可能需要先设置PowerShell执行策略：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 测试项目详细说明

### 1. WARP状态检测
- 通过访问 Cloudflare 的 trace 接口检测WARP状态
- 确保WARP正确工作后才进行后续测试

### 2. IP信息获取
- 使用 ipinfo.io 服务获取详细IP信息
- 验证WARP是否成功改变了网络出口

### 3. Ping延迟测试
测试到以下DNS服务器的延迟：
- Google DNS (8.8.8.8)
- Cloudflare DNS (1.1.1.1) 
- 腾讯DNS (119.29.29.29)
- 阿里DNS (223.5.5.5)

### 4. HTTP下载速度测试
- 10MB文件：快速测试基本下载速度
- 100MB文件：测试持续下载性能
- 结果以Mbps显示

### 5. 网站连接测试
测试主要网站的连接响应时间：
- Google、YouTube、Netflix
- ChatGPT、GitHub
- 百度（国内网站对比）

### 6. 流媒体解锁测试
- **Netflix**：检测是否支持Netflix流媒体
- **YouTube Premium**：检测YouTube Premium访问状态

## 输出示例

```
=== 检测WARP状态 ===
[INFO] WARP状态: 已开启 (plus)

=== 获取IP信息 ===
获取IPv4信息... ✓
  IPv4: 162.159.195.1
  位置: Los Angeles, US
  运营商: AS13335 Cloudflare, Inc.

=== Ping延迟测试 ===
Ping Google DNS (8.8.8.8)... ✓ 15ms
Ping Cloudflare DNS (1.1.1.1)... ✓ 8ms
Ping 腾讯DNS (119.29.29.29)... ✓ 180ms
Ping 阿里DNS (223.5.5.5)... ✓ 175ms

=== HTTP下载测速 ===
测试 10MB 文件下载速度... ✓ 85.32 Mbps
测试 100MB 文件下载速度... ✓ 92.15 Mbps

=== 网站连接测试 ===
测试 Google 连接... ✓ 120ms (HTTP 200)
测试 YouTube 连接... ✓ 135ms (HTTP 200)
测试 Netflix 连接... ✓ 180ms (HTTP 200)

=== 流媒体解锁测试 ===
测试 Netflix 解锁状态... ✓ 支持
测试 YouTube Premium 地区... ✓ 可访问
```

## 故障排除

### 常见问题

1. **"WARP状态: 未开启"**
   - 解决：先开启WARP：`warp o`

2. **"缺少必要命令"**
   - Linux/macOS：安装curl和ping
   - Windows：确保PowerShell版本支持Invoke-WebRequest

3. **网络测试失败**
   - 检查网络连接
   - 确认防火墙设置
   - 尝试切换WARP IP：`warp i`

4. **下载速度异常**
   - 可能的原因：
     - WARP IP质量问题
     - 本地网络限制
     - 测试服务器繁忙
   - 解决方案：多次测试或更换WARP IP

### 性能参考标准

- **优秀**：下载速度 > 50Mbps，延迟 < 50ms
- **良好**：下载速度 20-50Mbps，延迟 50-100ms  
- **一般**：下载速度 5-20Mbps，延迟 100-200ms
- **较差**：下载速度 < 5Mbps，延迟 > 200ms

## 技术说明

- 脚本使用IPv4进行所有网络测试
- 超时设置：ping测试3秒，HTTP测试10-30秒
- 错误处理：各项测试独立，单项失败不影响其他测试
- 跨平台支持：Bash和PowerShell版本功能一致

## 更新日志

### v1.0
- 初始版本
- 支持基本的WARP网络性能测试
- 包含Linux/macOS和Windows版本
