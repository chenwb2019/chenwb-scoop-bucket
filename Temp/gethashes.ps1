# 文件哈希计算自动化脚本
Write-Host "=== 文件哈希值计算工具 ===" -ForegroundColor Green

# 获取用户输入的URL
$url = Read-Host "请输入文件的完整URL"

# 验证URL格式
if (-not [System.Uri]::IsWellFormedUriString($url, [System.UriKind]::Absolute)) {
    Write-Host "错误: 提供的URL格式不正确" -ForegroundColor Red
    exit 1
}

# 从URL中提取文件名
try {
    $uri = [System.Uri]$url
    $fileName = [System.IO.Path]::GetFileName($uri.LocalPath)

    if ([string]::IsNullOrEmpty($fileName)) {
        $fileName = "download_file"
    }
} catch {
    Write-Host "错误: 无法解析URL" -ForegroundColor Red
    exit 1
}

# 设置临时文件路径
$tempDir = $env:TEMP
$localPath = Join-Path -Path $tempDir -ChildPath $fileName

Write-Host "正在下载文件: $fileName" -ForegroundColor Yellow

try {
    # 下载文件并显示进度
    Invoke-WebRequest -Uri $url -OutFile $localPath -ErrorAction Stop
} catch {
    Write-Host "下载失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

if (Test-Path $localPath) {
    Write-Host "下载完成，正在计算SHA256哈希值..." -ForegroundColor Yellow

    # 计算文件哈希值
    try {
        $hash = (Get-FileHash -Path $localPath -Algorithm SHA256 -ErrorAction Stop).Hash.ToLower()
        Write-Host "`n=== 计算结果 ===" -ForegroundColor Green
        Write-Host "文件: $fileName" -ForegroundColor White
        Write-Host "URL: $url" -ForegroundColor White
        Write-Host "SHA256: $hash" -ForegroundColor Cyan

        # 尝试将哈希值复制到剪贴板
        try {
            Set-Clipboard -Value $hash
            Write-Host "哈希值已复制到剪贴板" -ForegroundColor Green
        } catch {
            Write-Host "提示: 无法自动复制到剪贴板，请手动复制上面的哈希值" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "计算哈希值时出错: $($_.Exception.Message)" -ForegroundColor Red
    }

    # 清理临时文件
    try {
        Remove-Item $localPath -Force
        Write-Host "临时文件已清理" -ForegroundColor Green
    } catch {
        Write-Host "警告: 无法删除临时文件 $localPath" -ForegroundColor Yellow
    }
} else {
    Write-Host "错误: 文件下载后不存在" -ForegroundColor Red
}

Write-Host "`n操作完成" -ForegroundColor Green
Pause # 等待用户按键后再关闭窗口
