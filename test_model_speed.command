#!/bin/bash
# ================================================================
# 模型下载速度测试脚本 (macOS)
# 使用方法: chmod +x test_model_speed.command && ./test_model_speed.command
# ================================================================

# 配置区域
TIMEOUT=30  # 超时时间（秒）
# 如果需要代理，取消下面注释并填入你的代理地址
# export HTTP_PROXY="http://127.0.0.1:7890"
# export HTTPS_PROXY="http://127.0.0.1:7890"

# 模型列表
declare -a MODELS=(
    "1|Gemma 2 2B Abliterated|bartowski/gemma-2-2b-it-abliterated-GGUF|gemma-2-2b-it-abliterated-Q4_K_M.gguf|1.6GB|热门"
    "2|Gemma 4 E4B Heretic|llmfan46/gemma-4-E4B-it-ultra-uncensored-heretic-GGUF|gemma-4-E4B-it-ultra-uncensored-heretic-Q4_K_M.gguf|5.3GB|小众"
    "3|Qwen 3.5 9B|HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive|Qwen3.5-9B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf|5.2GB|小众"
    "4|NemoMix 12B|bartowski/NemoMix-Unleashed-12B-GGUF|NemoMix-Unleashed-12B-Q4_K_M.gguf|7.0GB|热门"
    "5|Dolphin 2.9 8B|bartowski/dolphin-2.9-llama3-8b-GGUF|dolphin-2.9-llama3-8b-Q4_K_M.gguf|4.9GB|热门"
    "6|Phi-3.5 Mini 3.8B|bartowski/Phi-3.5-mini-instruct-GGUF|Phi-3.5-mini-instruct-Q4_K_M.gguf|2.2GB|热门"
)

# 颜色定义
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
MAG='\033[0;35m'
WHT='\033[1;37m'
RST='\033[0m'

# 测试函数
test_url() {
    local name="$1"
    local url="$2"
    
    echo -n "  测试 $name... "
    
    # 使用curl测试，显示进度条
    start_time=$(python3 -c "import time; print(time.time())")
    
    response=$(curl -I -s -o /dev/null -w "%{http_code}|%{time_connect}|%{speed_download}" \
        --connect-timeout $TIMEOUT \
        --max-time $TIMEOUT \
        "$url" 2>/dev/null)
    
    end_time=$(python3 -c "import time; print(time.time())")
    
    if echo "$response" | grep -q "^200"; then
        status=$(echo "$response" | cut -d'|' -f1)
        connect_time=$(echo "$response" | cut -d'|' -f2)
        speed=$(echo "$response" | cut -d'|' -f3)
        elapsed=$(python3 -c "print(round($end_time - $start_time, 2))")
        
        echo -e "${GRN}✅ 成功${RST} (连接: ${connect_time}s, 总耗时: ${elapsed}s)"
        echo "       速度: $(python3 -c "print(f'{$speed/1024/1024:.2f} MB/s')")"
        return 0
    else
        echo -e "${RED}❌ 失败${RST} (状态码: $response)"
        return 1
    fi
}

# 主程序
clear
echo ""
echo -e "${CYN}═══════════════════════════════════════════════════════════════${RST}"
echo -e "${CYN}║${RST}       ${WHT}🔍 模型下载速度测试工具 (macOS)${RST}                    ${CYN}║${RST}"
echo -e "${CYN}═══════════════════════════════════════════════════════════════${RST}"
echo ""
echo -e "  超时设置: ${TIMEOUT}秒"
echo -e "  代理设置: ${HTTP_PROXY:-未设置}"
echo ""

# 检查网络
echo -n "  检查网络连接... "
if curl -I --connect-timeout 5 -s -o /dev/null "https://www.baidu.com" 2>/dev/null; then
    echo -e "${GRN}✅ 网络正常${RST}"
else
    echo -e "${RED}❌ 网络可能有问题${RST}"
fi
echo ""

# 测试每个模型
total_models=${#MODELS[@]}
current=1

for model_info in "${MODELS[@]}"; do
    IFS='|' read -r num name repo file size type <<< "$model_info"
    
    echo -e "${MAG}─────────────────────────────────────────────────────────────────${RST}"
    echo -e "${WHT}[$num] $name${RST}"
    echo -e "  📦 大小: $size | 🏷️ 类型: $type"
    echo ""
    
    # HuggingFace原始URL
    hf_url="https://huggingface.co/$repo/resolve/main/$file"
    test_url "HuggingFace 原始" "$hf_url"
    
    # HF Mirror URL
    mirror_url="https://hf-mirror.com/$repo/resolve/main/$file"
    test_url "HF Mirror 镜像" "$mirror_url"
    
    echo ""
    current=$((current + 1))
    
    # 避免请求过快
    sleep 1
done

# 汇总报告
echo -e "${CYN}═══════════════════════════════════════════════════════════════${RST}"
echo -e "${CYN}║${RST}                      ${WHT}📊 测试结果汇总${RST}                        ${CYN}║${RST}"
echo -e "${CYN}═══════════════════════════════════════════════════════════════${RST}"
echo ""
echo -e "  ${WHT}模型下载建议：${RST}"
echo ""
echo -e "  ${GRN}✅ 热门模型（bartowski仓库）：${RST}"
echo "     - Gemma 2 2B, NemoMix 12B, Dolphin 8B, Phi-3.5"
echo "     - 推荐使用 HF Mirror，通常更快"
echo ""
echo -e "  ${YLW}⚠️  小众模型（llmfan46, HauhauCS仓库）：${RST}"
echo "     - Gemma 4 Heretic, Qwen 3.5 9B"
echo "     - 可能镜像未同步，建议尝试原始URL"
echo ""
echo -e "${CYN}═══════════════════════════════════════════════════════════════${RST}"
echo -e "${CYN}║${RST}                      ${WHT}💡 优化建议${RST}                            ${CYN}║${RST}"
echo -e "${CYN}═══════════════════════════════════════════════════════════════${RST}"
echo ""
echo "  1. 如果镜像下载很慢，可以禁用镜像使用原始URL"
echo "  2. 如果原始URL很慢，可以启用镜像加速"
echo "  3. 小众仓库模型建议手动下载"
echo "  4. 脚本支持断点续传，中断后可继续"
echo ""
echo -e "${CYN}═══════════════════════════════════════════════════════════════${RST}"
echo ""
echo -e "${GRN}测试完成！按任意键退出...${RST}"
read -n 1 -s -r
