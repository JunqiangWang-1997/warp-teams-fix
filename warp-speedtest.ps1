# WARP IPv4 网络测速脚本 - Windows PowerShell版本
# 测试WARP连接的网络性能

param(
    [switch]$Quick,
    [switch]$Help
)

$VERSION = "1.0"

# 颜色输出函数
function Write-Info($message) {
    Write-Host "[INFO] $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

function Write-Title($message) {
    Write-Host "=== $message ===" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "✓ $message" -ForegroundColor Green
}

function Write-Failure($message) {
    Write-Host "✗ $message" -ForegroundColor Red
}

# 检测WARP状态
function Test-WarpStatus {
    Write-Title "检测WARP状态"
    
    try {
        $response = Invoke-RestMethod -Uri "https://www.cloudflare.com/cdn-cgi/trace" -TimeoutSec 5
        $warpLine = $response -split "`n" | Where-Object { $_ -like "warp=*" }
        
        if ($warpLine) {
            $warpStatus = $warpLine.Split('=')[1]
            if ($warpStatus -eq "on" -or $warpStatus -eq "plus") {
                Write-Info "WARP状态: 已开启 ($warpStatus)"
                return $true
            } else {
                Write-Warning "WARP状态: 未开启 ($warpStatus)"
                Write-Host "请先开启WARP"
                return $false
            }
        } else {
            Write-Warning "无法获取WARP状态"
            return $false
        }
    }
    catch {
        Write-Error "检测WARP状态失败: $($_.Exception.Message)"
        return $false
    }
}

# 获取IP信息
function Get-IpInfo {
    Write-Title "获取IP信息"
    
    try {
        Write-Host "获取IPv4信息... " -NoNewline
        $ipInfo = Invoke-RestMethod -Uri "https://ipinfo.io/json" -TimeoutSec 10
        
        Write-Success ""
        Write-Host "  IPv4: " -NoNewline -ForegroundColor White
        Write-Host $ipInfo.ip -ForegroundColor Blue
        Write-Host "  位置: " -NoNewline -ForegroundColor White
        Write-Host "$($ipInfo.city), $($ipInfo.country)" -ForegroundColor Blue
        Write-Host "  运营商: " -NoNewline -ForegroundColor White
        Write-Host $ipInfo.org -ForegroundColor Blue
    }
    catch {
        Write-Failure "获取IP信息失败"
    }
    
    Write-Host ""
}

# HTTP下载测速
function Test-HttpSpeed {
    Write-Title "HTTP下载测速"
    
    $testFiles = @{
        "10MB" = "http://speedtest.tele2.net/10MB.zip"
        "100MB" = "http://speedtest.tele2.net/100MB.zip"
    }
    
    foreach ($size in @("10MB", "100MB")) {
        Write-Host "测试 $size 文件下载速度... " -NoNewline
        
        try {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadData($testFiles[$size]) | Out-Null
            $stopwatch.Stop()
            
            $sizeBytes = switch ($size) {
                "10MB" { 10 * 1024 * 1024 }
                "100MB" { 100 * 1024 * 1024 }
            }
            
            $speedMbps = [math]::Round(($sizeBytes * 8) / ($stopwatch.Elapsed.TotalSeconds * 1024 * 1024), 2)
            Write-Host "✓ " -ForegroundColor Green -NoNewline
            Write-Host "$speedMbps Mbps" -ForegroundColor Blue
            
            $webClient.Dispose()
        }
        catch {
            Write-Failure "测试失败"
        }
        
        Start-Sleep -Seconds 1
    }
    
    Write-Host ""
}

# Ping测试
function Test-Ping {
    Write-Title "Ping延迟测试"
    
    $pingTargets = @{
        "Google DNS" = "8.8.8.8"
        "Cloudflare DNS" = "1.1.1.1"
        "腾讯DNS" = "119.29.29.29"
        "阿里DNS" = "223.5.5.5"
    }
    
    foreach ($name in $pingTargets.Keys) {
        $target = $pingTargets[$name]
        Write-Host "Ping $name ($target)... " -NoNewline
        
        try {
            $pingResult = Test-Connection -ComputerName $target -Count 3 -Quiet
            if ($pingResult) {
                $ping = Test-Connection -ComputerName $target -Count 3
                $avgTime = [math]::Round(($ping | Measure-Object -Property ResponseTime -Average).Average, 0)
                Write-Host "✓ " -ForegroundColor Green -NoNewline
                Write-Host "${avgTime}ms" -ForegroundColor Blue
            } else {
                Write-Failure "超时"
            }
        }
        catch {
            Write-Failure "测试失败"
        }
    }
    
    Write-Host ""
}

# 网站连接测试
function Test-WebsiteAccess {
    Write-Title "网站连接测试"
    
    $websites = @{
        "Google" = "https://www.google.com"
        "YouTube" = "https://www.youtube.com"
        "Netflix" = "https://www.netflix.com"
        "ChatGPT" = "https://chat.openai.com"
        "GitHub" = "https://github.com"
        "百度" = "https://www.baidu.com"
    }
    
    foreach ($site in $websites.Keys) {
        $url = $websites[$site]
        Write-Host "测试 $site 连接... " -NoNewline
        
        try {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing
            $stopwatch.Stop()
            
            $responseTime = [math]::Round($stopwatch.Elapsed.TotalMilliseconds, 0)
            
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
                Write-Host "✓ " -ForegroundColor Green -NoNewline
                Write-Host "${responseTime}ms (HTTP $($response.StatusCode))" -ForegroundColor Blue
            } else {
                Write-Host "⚠ " -ForegroundColor Yellow -NoNewline
                Write-Host "${responseTime}ms (HTTP $($response.StatusCode))" -ForegroundColor Blue
            }
        }
        catch {
            Write-Failure "连接失败"
        }
    }
    
    Write-Host ""
}

# 流媒体解锁测试
function Test-Streaming {
    Write-Title "流媒体解锁测试"
    
    Write-Host "测试 Netflix 解锁状态... " -NoNewline
    try {
        $netflixResponse = Invoke-WebRequest -Uri "https://www.netflix.com/title/70143836" -TimeoutSec 10 -UseBasicParsing
        
        if ($netflixResponse.Content -like "*Not Available*") {
            Write-Failure "不支持"
        } elseif ($netflixResponse.Content -like "*watch*" -or $netflixResponse.Content -like "*播放*") {
            Write-Success "支持"
        } else {
            Write-Host "? 未知" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Failure "测试失败"
    }
    
    Write-Host "测试 YouTube Premium 地区... " -NoNewline
    try {
        $youtubeResponse = Invoke-WebRequest -Uri "https://www.youtube.com/premium" -TimeoutSec 10 -UseBasicParsing
        Write-Success "可访问"
    }
    catch {
        Write-Failure "无法访问"
    }
    
    Write-Host ""
}

# 生成测速报告
function Write-Report {
    Write-Title "测速报告总结"
    
    Write-Host "测试时间: " -NoNewline -ForegroundColor Magenta
    Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Write-Host "测试版本: " -NoNewline -ForegroundColor Magenta
    Write-Host $VERSION
    Write-Host ""
    Write-Host "建议:" -ForegroundColor Cyan
    Write-Host "• 如果下载速度低于预期，可以尝试更换WARP IP"
    Write-Host "• 如果延迟较高，可以检查WARP的工作模式"
    Write-Host "• 如果网站无法访问，可能需要检查DNS设置"
    Write-Host ""
}

# 显示帮助
function Show-Help {
    Write-Host "WARP IPv4 测速脚本 - PowerShell版本"
    Write-Host ""
    Write-Host "用法: .\warp-speedtest.ps1 [参数]"
    Write-Host ""
    Write-Host "参数:"
    Write-Host "  -Quick        快速测试（跳过大文件下载）"
    Write-Host "  -Help         显示此帮助信息"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  .\warp-speedtest.ps1         # 完整测试"
    Write-Host "  .\warp-speedtest.ps1 -Quick  # 快速测试"
}

# 主函数
function Main {
    Clear-Host
    
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║               WARP IPv4 网络测速工具                     ║" -ForegroundColor Cyan
    Write-Host "║                PowerShell版本: $VERSION                    ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    if ($Help) {
        Show-Help
        return
    }
    
    # 执行测试
    if (Test-WarpStatus) {
        Get-IpInfo
        Test-Ping
        if (-not $Quick) {
            Test-HttpSpeed
        }
        Test-WebsiteAccess
        Test-Streaming
        Write-Report
    } else {
        Write-Error "请先开启WARP后再进行测试"
    }
}

# 执行主函数
Main
