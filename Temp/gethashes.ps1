# 改良的文件哈希计算脚本（兼容 CI / Windows PowerShell）
<#
.SYNOPSIS
  计算给定 URL 指向文件的 SHA256 哈希并输出结果。
.PARAMETER Url
  可选。要下载的文件 URL。CI 环境请通过参数或环境变量传入（避免交互）。
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

# 获取 URL：优先级 参数 > 环境变量 > repo/url.txt > stdin > 交互提示
if (-not $Url) {
    $envCandidates = @($env:URL, $env:INPUT_URL, $env:FILE_URL, $env:DOWNLOAD_URL)
    foreach ($e in $envCandidates) { if ($e) { $Url = $e; break } }

    if (-not $Url -and $env:GITHUB_WORKSPACE) {
        $p = Join-Path $env:GITHUB_WORKSPACE 'url.txt'
        if (Test-Path $p) { $Url = (Get-Content $p -Raw).Trim() }
    }

    if (-not $Url) {
        # 仅在 stdin 被重定向时从 stdin 读取，避免在交互式终端阻塞
        try {
            if ([Console]::IsInputRedirected) {
                $stdin = [Console]::In.ReadToEnd().Trim()
                if ($stdin) { $Url = $stdin }
            }
        } catch { }
    }

    if (-not $Url) {
        # 只有在交互式会话才提示，否则退出（便于 CI 判断失败）
        try {
            if ($Host -and $Host.UI -and $Host.UI.RawUI) {
                $Url = Read-Host "请输入文件的完整 URL（CI 请通过 env: URL 或参数传入）"
            } else {
                Write-Err "未提供 URL，且当前会话不可交互。请通过 -Url 参数或环境变量 URL 调用脚本。"
                exit 2
            }
        } catch {
            Write-Err "未提供 URL，且当前会话不可交互。请通过 -Url 参数或环境变量 URL 调用脚本。"
            exit 2
        }
    }
}

if (-not [System.Uri]::IsWellFormedUriString($Url, [System.UriKind]::Absolute)) {
    Write-Err "错误: 提供的 URL 格式不正确： $Url"
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

    if (Get-Command -Name Set-Clipboard -ErrorAction SilentlyContinue) {
        try { Set-Clipboard -Value $hash } catch { Write-Warn "无法复制到剪贴板：$($_.Exception.Message)" }
    } else {
        Write-Warn "当前环境不支持 Set-Clipboard，哈希已在输出中显示。"
    }
} catch {
    Write-Err "计算哈希值时出错: $($_.Exception.Message)"
    Remove-Item -Path $localPath -Force -ErrorAction SilentlyContinue
    exit 7
}

try { Remove-Item $localPath -Force -ErrorAction SilentlyContinue } catch {}
Write-Info "`n操作完成"
exit 0
