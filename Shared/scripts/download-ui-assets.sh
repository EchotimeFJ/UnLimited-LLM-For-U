#!/usr/bin/env bash
set -u

VENDOR_DIR="${1:-}"
if [ -z "$VENDOR_DIR" ]; then
  echo "Usage: $0 <vendor_dir>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUERY_SCRIPT="$SCRIPT_DIR/config_query.py"

if command -v python3 >/dev/null 2>&1; then
  PY_CMD="python3"
elif command -v python >/dev/null 2>&1; then
  PY_CMD="python"
else
  echo "      WARNING: Python not found; cannot parse shared JSON config for UI assets."
  exit 0
fi

mkdir -p "$VENDOR_DIR"

# ----------------------------------------------------------------
# 检查文件是否已存在且有效
# ----------------------------------------------------------------
check_existing_file() {
    local name="$1"
    local dest="$VENDOR_DIR/$name"
    
    if [ -f "$dest" ]; then
        local bytes="$(wc -c < "$dest" 2>/dev/null || echo 0)"
        # 检查文件是否大于1KB（基本有效性检查）
        if [ "${bytes:-0}" -gt 1024 ]; then
            echo "      [已存在] $name (${bytes} bytes)"
            return 0
        else
            echo "      [无效文件] $name - 将重新下载"
            rm -f "$dest"
            return 1
        fi
    fi
    return 1
}

download_file() {
    local url="$1"
    local dest="$2"
    local name="$3"
    
    if [ -f "$dest" ]; then
        local bytes="$(wc -c < "$dest" 2>/dev/null || echo 0)"
        if [ "${bytes:-0}" -gt 1024 ]; then
            echo "      [已存在] $name"
            return 0
        fi
    fi
    
    echo "      -> $name"
    
    if command -v curl >/dev/null 2>&1; then
        curl -L --retry 3 --retry-delay 2 -f -o "$dest" "$url" 2>/dev/null
        local rc=$?
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$dest"
        local rc=$?
    else
        return 127
    fi
    
    if [ $rc -ne 0 ]; then
        rm -f "$dest"
        echo "         WARNING: Could not fetch $name. UI will fallback when online."
        return 1
    fi
    
    # 验证下载的文件
    local bytes="$(wc -c < "$dest" 2>/dev/null || echo 0)"
    if [ "${bytes:-0}" -lt 1024 ]; then
        rm -f "$dest"
        echo "         WARNING: $name was too small. UI will fallback when online."
        return 1
    fi
    
    # Patch Font Awesome CSS so font paths resolve from ./vendor/ instead of ../webfonts/
    if [ "$name" = "fa-all.min.css" ]; then
        sed -i 's|\.\./webfonts/|./|g' "$dest" 2>/dev/null || \
        sed -i '' 's|\.\./webfonts/|./|g' "$dest" 2>/dev/null || true
    fi
    
    return 0
}

# ----------------------------------------------------------------
# 统计已下载的文件
# ----------------------------------------------------------------
echo "      检查UI assets状态..."

DOWNLOADED_COUNT=0
TOTAL_COUNT=0
ALREADY_EXISTS=0

# 先统计总数
while IFS='|' read -r name url; do
    [ -z "${name:-}" ] && continue
    [ -z "${url:-}" ] && continue
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
done < <("$PY_CMD" "$QUERY_SCRIPT" vendors)

if [ $TOTAL_COUNT -eq 0 ]; then
    echo "      没有找到UI assets配置，跳过。"
    exit 0
fi

# 检查已存在的文件
while IFS='|' read -r name url; do
    [ -z "${name:-}" ] && continue
    [ -z "${url:-}" ] && continue
    
    if check_existing_file "$name"; then
        ALREADY_EXISTS=$((ALREADY_EXISTS + 1))
    fi
done < <("$PY_CMD" "$QUERY_SCRIPT" vendors)

echo "      已存在: $ALREADY_EXISTS / $TOTAL_COUNT"

# 如果所有文件都已存在，跳过下载
if [ $ALREADY_EXISTS -eq $TOTAL_COUNT ]; then
    echo "      [✓] 所有UI assets已存在，无需下载。"
    echo "      UI asset bootstrap complete."
    exit 0
fi

echo "      Downloading shared UI vendor assets..."
while IFS='|' read -r name url; do
    [ -z "${name:-}" ] && continue
    [ -z "${url:-}" ] && continue
    
    dest="$VENDOR_DIR/$name"
    download_file "$url" "$dest" "$name"
    DOWNLOADED_COUNT=$((DOWNLOADED_COUNT + 1))
done < <("$PY_CMD" "$QUERY_SCRIPT" vendors)

echo ""
if [ $DOWNLOADED_COUNT -gt 0 ]; then
    echo "      [✓] 新下载: $DOWNLOADED_COUNT 个文件"
fi
echo "      UI asset bootstrap complete."
