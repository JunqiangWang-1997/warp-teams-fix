# WARP Teams IPv6修复版

这是对原版WARP脚本的修复版本，主要解决了Teams账户登录时的IPv6地址解析问题。

## 修复内容

### 主要问题
原版脚本在处理Teams账户的IPv6地址时存在以下问题：
1. IPv6地址提取正则表达式在遇到方括号时停止匹配
2. 无法正确处理包含端口号的IPv6地址格式（如：`[2606:4700:100:1a2af:c103]:0`）
3. IPv6地址验证规则过于严格，不支持某些有效的压缩格式

### 修复方案
1. **IPv6地址提取修复**：
   - 修改正则表达式从 `\([^["]\+\)` 改为 `\([^"]\+\)`
   - 添加IPv6地址清理逻辑，自动移除方括号和端口号

2. **IPv6地址验证增强**：
   - 支持标准8组IPv6格式
   - 支持IPv6压缩格式（`::`）
   - 支持各种有效的IPv6变体格式

3. **兼容性改进**：
   - 同时修复了URL文件和Token方式的IPv6地址处理
   - 保持与原脚本的完全兼容性

## 安装方法

### 方法1：一键安装（推荐）
```bash
wget -N https://raw.githubusercontent.com/YOUR_USERNAME/warp-script-fixed/main/install-fixed.sh && bash install-fixed.sh
```

### 方法2：手动安装
```bash
# 下载脚本
wget -N https://raw.githubusercontent.com/YOUR_USERNAME/warp-script-fixed/main/menu.sh

# 设置权限并安装
chmod +x menu.sh
sudo mkdir -p /etc/wireguard/
sudo mv menu.sh /etc/wireguard/
sudo ln -sf /etc/wireguard/menu.sh /usr/bin/warp

# 运行
warp
```

## 使用方法

### Teams账户登录
1. 运行 `warp a` 选择更换账户
2. 选择 `3` - Teams账户
3. 选择登录方式：
   - **方式2**（推荐）：输入组织名和邮箱验证码
   - 方式1：通过URL文件
   - 方式3：手动输入配置
   - 方式4：使用共享账户

### Teams邮箱验证流程
1. 输入您的组织名（如：`your-org-name`）
2. 输入您的邮箱地址
3. 检查邮箱收到的6位验证码
4. 输入验证码完成验证

## 修复验证

修复后，Teams账户信息应该显示：
- ✅ Private key: `正确的私钥格式`
- ✅ Address IPv6: `正确的IPv6地址` （符合）
- ✅ Client id: `[数字,数字,数字]` （符合）

## 支持的系统

- Ubuntu 16.04+
- Debian 9+
- CentOS 7+
- Alpine Linux
- Arch Linux

## 版本信息

- **当前版本**: 3.1.6-fixed
- **基于版本**: 3.1.6
- **修复日期**: 2025年8月19日

## 问题反馈

如果在使用过程中遇到问题，请提供以下信息：
1. 系统版本 (`cat /etc/os-release`)
2. 错误信息截图
3. 详细的操作步骤

## 免责声明

本修复版本基于开源WARP脚本进行修改，仅用于修复Teams账户IPv6地址解析问题。使用前请确保了解相关风险。

## 原版项目

原版脚本项目：https://github.com/fscarmen/warp-sh

---

**注意**：请在上传到GitHub后将所有 `YOUR_USERNAME` 替换为您的实际GitHub用户名。
