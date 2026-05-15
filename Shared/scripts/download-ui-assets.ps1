param(
    [Parameter(Mandatory = $true)]
    [string]$VendorDir
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $ScriptDir "..\config\ui-vendor-assets.json"

New-Item -ItemType Directory -Force -Path $VendorDir | Out-Null

Write-Host "      检查UI assets状态..." -ForegroundColor DarkGray

try {
    $json = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
} catch {
    Write-Host "      WARNING: Could not read UI vendor JSON config. Skipping." -ForegroundColor Yellow
    exit 0
}

$totalCount = $json.assets.Count
$alreadyExists = 0
$toDownload = @()

# 检查已存在的文件
foreach ($asset in $json.assets) {
    $name = [string]$asset.name
    $url = [string]$asset.url
    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($url)) { continue }
    
    $dest = Join-Path $VendorDir $name
    if (Test-Path $dest) {
        $fileSize = (Get-Item $dest).Length
        if ($fileSize -gt 1024) {
            Write-Host "      [已存在] $name ($([math]::Round($fileSize/1024, 2)) KB)" -ForegroundColor DarkGray
            $alreadyExists++
            continue
        } else {
            Write-Host "      [无效文件] $name - 将重新下载" -ForegroundColor Yellow
            Remove-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
        }
    }
    $toDownload += $asset
}

Write-Host "      已存在: $alreadyExists / $totalCount" -ForegroundColor DarkGray

# 如果所有文件都已存在，跳过下载
if ($toDownload.Count -eq 0) {
    Write-Host "      [✓] 所有UI assets已存在，无需下载。" -ForegroundColor Green
    Write-Host "      UI asset bootstrap complete." -ForegroundColor Green
    exit 0
}

Write-Host "      正在下载UI assets..." -ForegroundColor Yellow

foreach ($asset in $toDownload) {
    $name = [string]$asset.name
    $url = [string]$asset.url
    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($url)) { continue }
    
    $dest = Join-Path $VendorDir $name
    Write-Host "      -> $name" -ForegroundColor DarkGray
    
    try {
        curl.exe -L --ssl-no-revoke --retry 3 --retry-delay 2 -f -o $dest $url
        if (-Not (Test-Path $dest) -or (Get-Item $dest).Length -lt 1024) {
            throw "Downloaded file missing/too small"
        }
        
        # Patch Font Awesome CSS so font paths resolve from ./vendor/ instead of ../webfonts/
        if ($name -eq "fa-all.min.css") {
            (Get-Content -Raw $dest) -replace '\.\.\/webfonts\/', './' | Set-Content -NoNewline $dest
        }
        
        Write-Host "      [✓] $name 下载完成" -ForegroundColor Green
    } catch {
        if (Test-Path $dest) {
            Remove-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
        }
        Write-Host "         WARNING: Could not fetch $name. UI will fallback when online." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "      [✓] 新下载: $($toDownload.Count) 个文件" -ForegroundColor Green
Write-Host "      UI asset bootstrap complete." -ForegroundColor Green
