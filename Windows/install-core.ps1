# ================================================================
# PORTABLE UNCENSORED AI - AUTOMATED USB SETUP SCRIPT
# ================================================================
# Multi-Model Edition: Choose one or more AI models to install!
# Supports preset models + custom HuggingFace GGUF downloads.
# 优化版：添加HuggingFace镜像支持和断点续传
# ================================================================

$ErrorActionPreference = "Continue"
$USB_Drive = (Get-Item $MyInvocation.MyCommand.Path).Directory.Parent.FullName

# ==================== 配置区域 ====================
$Global:HFMirror = "https://hf-mirror.com"
$Global:MaxRetries = 5
$Global:RetryDelay = 3
$Global:UseMirror = $true
# ==================== 配置区域 ====================

# -----------------------------------------------------------------
# MODEL CATALOG (shared JSON config)
# -----------------------------------------------------------------
$modelsConfigPath = "$USB_Drive\Shared\config\models.json"
if (-Not (Test-Path $modelsConfigPath)) {
    Write-Host "ERROR: Missing shared model config at $modelsConfigPath" -ForegroundColor Red
    exit 1
}

try {
    $modelsJson = Get-Content -Raw -Path $modelsConfigPath | ConvertFrom-Json
    $ModelCatalog = @()
    foreach ($m in $modelsJson.desktop_models) {
        $ModelCatalog += @{
            Num      = [int]$m.num
            Name     = [string]$m.name
            File     = [string]$m.file
            URL      = [string]$m.url
            Size     = [string]$m.size
            MinBytes = [long]$m.min_bytes
            Local    = [string]$m.local
            Label    = [string]$m.label
            Badge    = [string]$m.badge
            Prompt   = [string]$m.prompt
        }
    }
} catch {
    Write-Host "ERROR: Failed to parse shared model config: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# -----------------------------------------------------------------
# HELPER: Convert HuggingFace URL to mirror URL
# -----------------------------------------------------------------
function Get-MirroredURL {
    param([string]$URL)
    if ($UseMirror -and $URL -match "huggingface\.co") {
        $relativePath = $URL -replace "https?://huggingface\.co/", ""
        return "$HFMirror/$relativePath"
    }
    return $URL
}

# -----------------------------------------------------------------
# HELPER: Download with resume support
# -----------------------------------------------------------------
function Download-WithResume {
    param(
        [string]$URL,
        [string]$Dest,
        [long]$MinSize,
        [string]$Name
    )

    $retryCount = 0
    $mirroredURL = Get-MirroredURL -URL $URL

    while ($retryCount -lt $MaxRetries) {
        $retryCount++
        Write-Host "      [尝试 $retryCount/$MaxRetries] 正在下载 $Name..." -ForegroundColor Cyan

        try {
            $existingSize = 0
            $continueFlag = ""

            if (Test-Path $Dest) {
                $existingSize = (Get-Item $Dest).Length
                if ($existingSize -gt 0) {
                    $continueFlag = "-C $existingSize"
                    Write-Host "      检测到已下载 $('{0:N2}' -f ($existingSize/1MB)) MB，继续下载..." -ForegroundColor DarkGray
                }
            }

            $ProgressPreference = 'SilentlyContinue'
            curl.exe -L --ssl-no-revoke $continueFlag `
                     --retry 3 --retry-delay 2 `
                     --progress-bar `
                     -f -o $Dest $mirroredURL

            if ($LASTEXITCODE -eq 0 -and (Test-DownloadedFile -Path $Dest -MinSize $MinSize)) {
                $fileSize = [math]::Round((Get-Item $Dest).Length / 1GB, 2)
                Write-Host "      [✓] $Name 下载成功！ ($('{0:N2}' -f $fileSize) GB)" -ForegroundColor Green
                return $true
            }

            if (Test-Path $Dest) {
                $actualSize = [math]::Round((Get-Item $Dest).Length / 1GB, 2)
                Write-Host "      文件不完整 ($actualSize GB)，重试中..." -ForegroundColor Yellow
            }

        } catch {
            Write-Host "      下载出错: $($_.Exception.Message)" -ForegroundColor Yellow
        }

        if ($retryCount -lt $MaxRetries) {
            Write-Host "      ${RetryDelay}秒后重试..." -ForegroundColor Yellow
            Start-Sleep -Seconds $RetryDelay
        }
    }

    Write-Host "      [✗] $Name 下载失败（已重试 $MaxRetries 次）" -ForegroundColor Red
    return $false
}

# -----------------------------------------------------------------
# HELPER: Check USB free space (returns GB)
# -----------------------------------------------------------------
function Get-USBFreeSpaceGB {
    try {
        $driveLetter = (Get-Item $USB_Drive).PSDrive.Name
        $drive = Get-PSDrive $driveLetter -ErrorAction SilentlyContinue
        if ($drive) {
            return [math]::Round($drive.Free / 1GB, 1)
        }
    } catch {}
    return -1
}

# -----------------------------------------------------------------
# HELPER: Verify downloaded file size
# -----------------------------------------------------------------
function Test-DownloadedFile {
    param([string]$Path, [long]$MinSize)
    if (-Not (Test-Path $Path)) { return $false }
    $fileSize = (Get-Item $Path).Length
    return $fileSize -gt $MinSize
}

# ================================================================
# START
# ================================================================
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   PORTABLE AI USB - 优化版安装程序                      " -ForegroundColor Cyan
Write-Host "   [HuggingFace镜像加速 + 断点续传]" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "  使用镜像加速: $(if ($UseMirror) { '是 (hf-mirror.com)' } else { '否' })" -ForegroundColor DarkGray
Write-Host ""

$freeGB = Get-USBFreeSpaceGB
if ($freeGB -gt 0) {
    Write-Host "  USB Free Space: $freeGB GB" -ForegroundColor DarkGray
    Write-Host ""
}

# =================================================================
# STEP 1: MODEL SELECTION MENU
# =================================================================
Write-Host "[1/7] Choose your AI model(s):" -ForegroundColor Yellow
Write-Host ""

foreach ($m in $ModelCatalog) {
    $numStr   = "  [$($m.Num)]"
    $nameStr  = " $($m.Name)"
    $sizeStr  = " (~$($m.Size) GB)"

    if ($m.Label -eq "UNCENSORED") {
        $labelStr   = " [UNCENSORED]"
        $labelColor = "Red"
    } else {
        $labelStr   = " [STANDARD]"
        $labelColor = "DarkCyan"
    }

    $badgeStr = ""
    if ($m.Badge) { $badgeStr = " - $($m.Badge)" }

    Write-Host $numStr  -ForegroundColor Yellow    -NoNewline
    Write-Host $nameStr -ForegroundColor White     -NoNewline
    Write-Host $sizeStr -ForegroundColor DarkGray  -NoNewline
    Write-Host $labelStr -ForegroundColor $labelColor -NoNewline
    Write-Host $badgeStr -ForegroundColor Magenta
}

Write-Host ""
Write-Host "  [C] CUSTOM - Enter your own HuggingFace GGUF URL" -ForegroundColor Green
Write-Host ""
Write-Host "  ------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Enter number(s) separated by commas  (e.g. 1,3)" -ForegroundColor Gray
Write-Host "  Type 'all' for every preset model" -ForegroundColor Gray
Write-Host "  Type 'c' to add a custom model" -ForegroundColor Gray
Write-Host "  Mix them!  (e.g. 1,3,c)" -ForegroundColor Gray
Write-Host ""

$UserChoice = Read-Host "  Your choice"

if ([string]::IsNullOrWhiteSpace($UserChoice)) {
    Write-Host ""
    Write-Host "  No input! Defaulting to [1] Gemma 2 2B (recommended)..." -ForegroundColor Yellow
    $UserChoice = "1"
}

# -----------------------------------------------------------------
# Parse the user's selection
# -----------------------------------------------------------------
$SelectedModels = @()
$HasCustom = $false

if ($UserChoice.Trim().ToLower() -eq "all") {
    $SelectedModels = @($ModelCatalog)
} else {
    $tokens = $UserChoice -split ","
    foreach ($token in $tokens) {
        $t = $token.Trim().ToLower()
        if ($t -eq "c" -or $t -eq "custom") {
            $HasCustom = $true
        } elseif ($t -match '^\d+$') {
            $num = [int]$t
            $found = $ModelCatalog | Where-Object { $_.Num -eq $num }
            if ($found) {
                $alreadyAdded = $SelectedModels | Where-Object { $_.Num -eq $num }
                if (-Not $alreadyAdded) {
                    $SelectedModels += $found
                }
            } else {
                Write-Host "  Invalid number '$num' - skipping (valid: 1-$($ModelCatalog.Count))" -ForegroundColor Red
            }
        } else {
            Write-Host "  Unrecognized input '$t' - skipping" -ForegroundColor Red
        }
    }
}

# -----------------------------------------------------------------
# Handle custom model input
# -----------------------------------------------------------------
if ($HasCustom) {
    Write-Host ""
    Write-Host "  ---- Custom Model Setup ----" -ForegroundColor Green
    Write-Host "  Paste a direct link to a .gguf file from HuggingFace." -ForegroundColor Gray
    Write-Host "  Example: https://huggingface.co/user/model-GGUF/resolve/main/model-Q4_K_M.gguf" -ForegroundColor DarkGray
    Write-Host ""

    $customURL = Read-Host "  GGUF URL"

    if ([string]::IsNullOrWhiteSpace($customURL)) {
        Write-Host "  No URL entered - skipping custom model." -ForegroundColor Red
    } elseif ($customURL -notmatch "\.gguf") {
        Write-Host "  WARNING: URL does not end in .gguf - this may not be a valid model file." -ForegroundColor Red
        $proceed = Read-Host "  Try anyway? (yes/no)"
        if ($proceed.Trim().ToLower() -ne "yes" -and $proceed.Trim().ToLower() -ne "y") {
            Write-Host "  Skipping custom model." -ForegroundColor Yellow
            $customURL = $null
        }
    }

    if ($customURL) {
        $customFile = $customURL.Split("/")[-1].Split("?")[0]
        if (-Not $customFile.EndsWith(".gguf")) { $customFile = "$customFile.gguf" }

        $customLocalName = Read-Host "  Give it a short name (e.g. mymodel-local)"
        if ([string]::IsNullOrWhiteSpace($customLocalName)) {
            $customLocalName = "custom-local"
        }
        $customLocalName = $customLocalName.Trim().ToLower() -replace '\s+', '-'
        if ($customLocalName -notmatch '-local$') { $customLocalName = "$customLocalName-local" }

        $customPrompt = Read-Host "  System prompt (press Enter for default)"
        if ([string]::IsNullOrWhiteSpace($customPrompt)) {
            $customPrompt = "You are a helpful AI assistant."
        }

        $customModel = @{
            Num      = 99
            Name     = "Custom: $customFile"
            File     = $customFile
            URL      = $customURL.Trim()
            Size     = "?"
            MinBytes = 100000000
            Local    = $customLocalName
            Label    = "CUSTOM"
            Badge    = ""
            Prompt   = $customPrompt
        }

        $SelectedModels += $customModel
        Write-Host "  Custom model added!" -ForegroundColor Green
    }
}

# -----------------------------------------------------------------
# Validate we have at least one model
# -----------------------------------------------------------------
if ($SelectedModels.Count -eq 0) {
    Write-Host ""
    Write-Host "  ERROR: No models selected!" -ForegroundColor Red
    Write-Host "  Please run the installer again and pick at least one model." -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    exit 1
}

# -----------------------------------------------------------------
# USB space warning (if selecting 3+ models or all)
# -----------------------------------------------------------------
$totalSizeGB = 0
foreach ($m in $SelectedModels) {
    if ($m.Size -ne "?") { $totalSizeGB += [double]$m.Size }
}

if ($SelectedModels.Count -ge 3 -or $UserChoice.Trim().ToLower() -eq "all") {
    Write-Host ""
    Write-Host "  =============================================" -ForegroundColor Red
    Write-Host "  WARNING: You selected $($SelectedModels.Count) models!" -ForegroundColor Red
    Write-Host "  Estimated download: ~$totalSizeGB GB" -ForegroundColor Red
    $neededGB = [math]::Ceiling($totalSizeGB + 4)
    Write-Host "  USB drive needs at least ~$neededGB GB free!" -ForegroundColor Red

    if ($freeGB -gt 0 -and $freeGB -lt $neededGB) {
        Write-Host ""
        Write-Host "  You only have $freeGB GB free - this may NOT fit!" -ForegroundColor Yellow
    }

    Write-Host "  =============================================" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "  Continue? (yes/no)"
    if ($confirm.Trim().ToLower() -ne "yes" -and $confirm.Trim().ToLower() -ne "y") {
        Write-Host "  Cancelled. Run the installer again to choose fewer models." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        exit
    }
}

# -----------------------------------------------------------------
# Show selection summary
# -----------------------------------------------------------------
Write-Host ""
Write-Host "  Selected $($SelectedModels.Count) model(s):" -ForegroundColor Green
foreach ($m in $SelectedModels) {
    $sizeInfo = if ($m.Size -ne "?") { " (~$($m.Size) GB)" } else { "" }
    Write-Host "    + $($m.Name)$sizeInfo" -ForegroundColor White
}
Write-Host ""

# =================================================================
# STEP 2: Create folder structure
# =================================================================
Write-Host "[2/7] Verifying USB folder structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$USB_Drive\Shared\models" | Out-Null
New-Item -ItemType Directory -Force -Path "$USB_Drive\Shared\bin" | Out-Null
New-Item -ItemType Directory -Force -Path "$USB_Drive\Shared\vendor" | Out-Null
Write-Host "      Done." -ForegroundColor Green

# =================================================================
# STEP 3: Download optional UI vendor assets for offline mode
# =================================================================
Write-Host ""
Write-Host "[3/7] Downloading UI assets (offline markdown/pdf/fonts)..." -ForegroundColor Yellow

$vendorDir = "$USB_Drive\Shared\vendor"
$vendorScript = "$USB_Drive\Shared\scripts\download-ui-assets.ps1"
if (Test-Path $vendorScript) {
    powershell -ExecutionPolicy Bypass -File $vendorScript -VendorDir $vendorDir
} else {
    Write-Host "      WARNING: Shared vendor bootstrap script not found. Skipping." -ForegroundColor Yellow
}

# =================================================================
# STEP 4: Download selected AI models (with resume support)
# =================================================================
Write-Host ""
Write-Host "[4/7] Downloading AI Model(s)..." -ForegroundColor Yellow
Write-Host "      使用HuggingFace镜像加速下载 (hf-mirror.com)" -ForegroundColor Cyan

$downloadErrors = @()
$modelIndex = 0

foreach ($m in $SelectedModels) {
    $modelIndex++
    $dest = "$USB_Drive\Shared\models\$($m.File)"
    $sizeInfo = if ($m.Size -ne "?") { "(~$($m.Size) GB)" } else { "" }

    Write-Host ""
    Write-Host "  ($modelIndex/$($SelectedModels.Count)) $($m.Name) $sizeInfo" -ForegroundColor Yellow

    if (Test-DownloadedFile -Path $dest -MinSize $m.MinBytes) {
        Write-Host "      Already downloaded! Skipping..." -ForegroundColor Green
        continue
    }

    if ($m.Local -eq "dolphin-local") {
        $legacyFile = "$USB_Drive\Shared\models\dolphin-2.9-llama3-8b-Q5_K_M.gguf"
        if (Test-DownloadedFile -Path $legacyFile -MinSize 4000000000) {
            Write-Host "      Found existing Dolphin Q5_K_M - using that instead!" -ForegroundColor Green
            $m.File = "dolphin-2.9-llama3-8b-Q5_K_M.gguf"
            continue
        }
    }

    Write-Host "      Downloading... 支持断点续传，请勿关闭窗口！" -ForegroundColor Magenta

    $success = Download-WithResume -URL $m.URL -Dest $dest -MinSize $m.MinBytes -Name $m.Name

    if (-not $success) {
        $downloadErrors += $m.Name
        Write-Host "      ERROR: Download failed for $($m.Name)!" -ForegroundColor Red
        Write-Host "      You can manually download it from:" -ForegroundColor DarkGray
        Write-Host "      $($m.URL)" -ForegroundColor DarkGray
        Write-Host "      Place the file in: $USB_Drive\Shared\models\" -ForegroundColor DarkGray
    }
}

# =================================================================
# STEP 5: Create Modelfile configuration for each model
# =================================================================
Write-Host ""
Write-Host "[5/7] Creating AI model configurations..." -ForegroundColor Yellow

foreach ($m in $SelectedModels) {
    $modelfilePath = "$USB_Drive\Shared\models\Modelfile-$($m.Local)"
    $modelfileContent = @"
FROM ./$($m.File)
PARAMETER temperature 0.7
PARAMETER top_p 0.9
SYSTEM $($m.Prompt)
"@
    Set-Content -Path $modelfilePath -Value $modelfileContent -Force -Encoding UTF8
    Write-Host "      Config: $($m.Name) -> $($m.Local)" -ForegroundColor Green
}

$firstModel = $SelectedModels[0]
$legacyModelfile = @"
FROM ./$($firstModel.File)
PARAMETER temperature 0.7
PARAMETER top_p 0.9
SYSTEM $($firstModel.Prompt)
"@
Set-Content -Path "$USB_Drive\Shared\models\Modelfile" -Value $legacyModelfile -Force -Encoding UTF8

$installedList = $SelectedModels | ForEach-Object { "$($_.Local)|$($_.Name)|$($_.Label)" }
Set-Content -Path "$USB_Drive\Shared\models\installed-models.txt" -Value ($installedList -join "`n") -Force -Encoding UTF8
Write-Host "      Saved model list to installed-models.txt" -ForegroundColor DarkGray

# =================================================================
# STEP 6: Download Ollama (the AI engine) - with mirror support
# =================================================================
Write-Host ""
Write-Host "[6/7] Downloading Ollama AI Engine (Windows)..." -ForegroundColor Yellow
Write-Host "      使用HuggingFace镜像加速" -ForegroundColor Cyan

$OllamaURLOriginal = "https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.zip"
$OllamaURLMirror = "https://hf-mirror.com/ollama/ollama-ecs/releases/latest/download/ollama-windows-amd64.zip"
$OllamaURL = $OllamaURLMirror
$OllamaDest = "$USB_Drive\Shared\bin\ollama-windows-amd64.zip"
$TempOllamaDir = "$USB_Drive\Shared\bin\temp_ollama"

if (Test-Path "$USB_Drive\Shared\bin\ollama-windows.exe") {
    Write-Host "      Ollama already installed! Skipping..." -ForegroundColor Green
} else {
    $retryCount = 0
    $success = $false

    while ($retryCount -lt $MaxRetries) {
        $retryCount++
        Write-Host "      [尝试 $retryCount/$MaxRetries] 正在下载 Ollama 引擎..." -ForegroundColor Cyan

        curl.exe -L --ssl-no-revoke --retry 3 --retry-delay 2 `
                 --progress-bar `
                 -f -o $OllamaDest $OllamaURL

        if ($LASTEXITCODE -eq 0 -and (Test-Path $OllamaDest) -and (Get-Item $OllamaDest).Length -gt 10000000) {
            $success = $true
            break
        }

        if ($retryCount -lt $MaxRetries) {
            Write-Host "      下载失败，${RetryDelay}秒后重试..." -ForegroundColor Yellow
            Start-Sleep -Seconds $RetryDelay

            if ($OllamaURL -eq $OllamaURLMirror) {
                Write-Host "      尝试使用备用镜像..." -ForegroundColor Yellow
                $OllamaURL = $OllamaURLOriginal
            }
        }
    }

    if ($success) {
        Write-Host "      [✓] Ollama 下载成功，正在解压..." -ForegroundColor Green
        try {
            New-Item -ItemType Directory -Force -Path $TempOllamaDir | Out-Null
            Expand-Archive -Path $OllamaDest -DestinationPath $TempOllamaDir -Force
            Move-Item -Path "$TempOllamaDir\ollama.exe" -Destination "$USB_Drive\Shared\bin\ollama-windows.exe" -Force
            Remove-Item $TempOllamaDir -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item $OllamaDest -Force -ErrorAction SilentlyContinue
            Write-Host "      [✓] Ollama 安装完成！" -ForegroundColor Green
        } catch {
            Write-Host "      ERROR: Failed to extract Ollama. Please extract manually." -ForegroundColor Red
            Write-Host "      File: $OllamaDest" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "      ERROR: Ollama download failed after $MaxRetries attempts!" -ForegroundColor Red
        $downloadErrors += "Ollama Engine"
    }
}

# =================================================================
# STEP 7: IMPORT ALL SELECTED MODELS INTO OLLAMA ENGINE
# =================================================================
Write-Host ""
Write-Host "[7/7] Importing AI models into the Ollama engine..." -ForegroundColor Yellow

if (-Not (Test-Path "$USB_Drive\Shared\bin\ollama-windows.exe")) {
    Write-Host "      ERROR: Ollama not found! Cannot import models." -ForegroundColor Red
    Write-Host "      Please re-run the installer to download Ollama." -ForegroundColor Red
} else {
    $env:OLLAMA_MODELS = "$USB_Drive\Shared\models\ollama_data"
    New-Item -ItemType Directory -Force -Path $env:OLLAMA_MODELS | Out-Null
    Set-Location "$USB_Drive\Shared\models"

    Stop-Process -Name "ollama-windows" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "ollama" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    $modelsToImport = @()
    foreach ($m in $SelectedModels) {
        $ggufPath = "$USB_Drive\Shared\models\$($m.File)"
        if (Test-Path $ggufPath) {
            $modelsToImport += $m
        } else {
            Write-Host "      Skipping $($m.Name) - GGUF file not found (download may have failed)" -ForegroundColor Red
        }
    }

    if ($modelsToImport.Count -gt 0) {
        Write-Host "      Starting Ollama temporarily to perform import..." -ForegroundColor DarkGray
        $ServerProcess = Start-Process -FilePath "$USB_Drive\Shared\bin\ollama-windows.exe" -ArgumentList "serve" -WindowStyle Hidden -PassThru
        Start-Sleep -Seconds 5

        foreach ($m in $modelsToImport) {
            Write-Host "      Importing $($m.Name)..." -ForegroundColor Yellow
            try {
                $null = & "$USB_Drive\Shared\bin\ollama-windows.exe" create $m.Local -f "Modelfile-$($m.Local)" 2>&1
                Write-Host "      $($m.Name) imported successfully!" -ForegroundColor Green
            } catch {
                Write-Host "      ERROR: Failed to import $($m.Name)" -ForegroundColor Red
            }
        }

        Write-Host "      Stopping temporary Ollama server..." -ForegroundColor DarkGray
        Stop-Process -Name "ollama-windows" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "ollama" -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "      No models to import!" -ForegroundColor Yellow
    }
}

# =================================================================
# FINAL SUMMARY
# =================================================================
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan

if ($downloadErrors.Count -gt 0) {
    Write-Host "   SETUP COMPLETE (with some errors)                      " -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  The following had issues:" -ForegroundColor Red
    foreach ($err in $downloadErrors) {
        Write-Host "    ! $err" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "  You can re-run install.bat to retry failed downloads." -ForegroundColor Yellow
} else {
    Write-Host "   SETUP COMPLETE! YOUR PORTABLE AI IS READY!             " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "  Installed models:" -ForegroundColor White
foreach ($m in $SelectedModels) {
    if ($m.Label -eq "UNCENSORED") {
        $tag = "[UNCENSORED]"
        $tagColor = "Red"
    } elseif ($m.Label -eq "CUSTOM") {
        $tag = "[CUSTOM]"
        $tagColor = "Green"
    } else {
        $tag = "[STANDARD]"
        $tagColor = "DarkCyan"
    }
    Write-Host "    - $($m.Name) " -ForegroundColor Gray -NoNewline
    Write-Host $tag -ForegroundColor $tagColor
}

Write-Host ""
Write-Host "  To start your AI: Double-click  Windows\start-fast-chat.bat" -ForegroundColor White
Write-Host "  On a Mac/Linux:   Run  start-fast-chat.sh from their folders" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to close this installer..." -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
