# 改良的文件哈希计算脚本（兼容 CI / Windows PowerShell）
<#
.SYNOPSIS
  计算给定 URL 指向文件的 SHA256 哈希并输出结果。
.PARAMETER Url
  可选。要下载的文件 URL。CI 环境请通过参数传入（避免交互）。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Url
)

function Write-Info { Write-Host $args -ForegroundColor Green }
function Write-Warn { Write-Host $args -ForegroundColor Yellow }
function Write-Err  { Write-Host $args -ForegroundColor Red }

Write-Info "=== 文件哈希值计算工具 ==="

if (-not $Url) {
    try {
        # 在交互式会话中提示；否则在 CI 中直接失败，避免挂起
        $Url = Read-Host "请输入文件的完整URL"
    } catch {
        Write-Err "未提供 URL，且当前会话不可交互。请通过 -Url 参数调用脚本。"
        exit 2
    }
}

if (-not [System.Uri]::IsWellFormedUriString($Url, [System.UriKind]::Absolute)) {
    Write-Err "错误: 提供的 URL 格式不正确"
    exit 3
}

try {
    $uri = [System.Uri]$Url
    $fileName = [System.IO.Path]::GetFileName($uri.LocalPath)
    if ([string]::IsNullOrEmpty($fileName)) { $fileName = "download_file" }
} catch {
    Write-Err "错误: 无法解析 URL"
    exit 4
}

$tempDir = [System.IO.Path]::GetTempPath()
$localPath = Join-Path -Path $tempDir -ChildPath $fileName

Write-Info "正在下载文件: $fileName"

try {
    Invoke-WebRequest -Uri $Url -OutFile $localPath -ErrorAction Stop
} catch {
    Write-Err "下载失败: $($_.Exception.Message)"
    exit 5
}

if (-not (Test-Path $localPath)) {
    Write-Err "错误: 文件下载后不存在"
    exit 6
}

Write-Info "下载完成，正在计算 SHA256 哈希值..."

try {
    $hash = (Get-FileHash -Path $localPath -Algorithm SHA256 -ErrorAction Stop).Hash.ToLower()
    Write-Info "`n=== 计算结果 ==="
    Write-Host "文件: $fileName" -ForegroundColor White
    Write-Host "URL: $Url" -ForegroundColor White
    Write-Host "SHA256: $hash" -ForegroundColor Cyan

    # 若运行环境支持 Set-Clipboard 则复制，否则仅输出
    if (Get-Command -Name Set-Clipboard -ErrorAction SilentlyContinue) {
        try {
            Set-Clipboard -Value $hash
            Write-Info "哈希值已复制到剪贴板"
        } catch {
            Write-Warn "无法复制到剪贴板：$($_.Exception.Message)"
        }
    } else {
        Write-Warn "当前环境不支持 Set-Clipboard，哈希已在输出中显示。"
    }
} catch {
    Write-Err "计算哈希值时出错: $($_.Exception.Message)"
    Remove-Item -Path $localPath -Force -ErrorAction SilentlyContinue
    exit 7
}

# 清理临时文件（遇错不终止）
try { Remove-Item $localPath -Force -ErrorAction SilentlyContinue } catch {}

Write-Info "`n操作完成"
exit 0
