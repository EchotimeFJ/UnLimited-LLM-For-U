#!/usr/bin/env python3
"""
模型下载速度测试脚本
使用方法: python3 test_download_speed.py
"""
import urllib.request
import urllib.error
import time
import sys
import os

# 配置超时（秒）
TIMEOUT = 30

# 模型列表
models = [
    {
        "id": 1,
        "name": "Gemma 2 2B Abliterated",
        "repo": "bartowski/gemma-2-2b-it-abliterated-GGUF",
        "file": "gemma-2-2b-it-abliterated-Q4_K_M.gguf",
        "size": "~1.6 GB",
        "type": "热门",
        "mirror_recommended": True
    },
    {
        "id": 2,
        "name": "Gemma 4 E4B Heretic",
        "repo": "llmfan46/gemma-4-E4B-it-ultra-uncensored-heretic-GGUF",
        "file": "gemma-4-E4B-it-ultra-uncensored-heretic-Q4_K_M.gguf",
        "size": "~5.3 GB",
        "type": "小众",
        "mirror_recommended": False
    },
    {
        "id": 3,
        "name": "Qwen 3.5 9B Aggressive",
        "repo": "HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive",
        "file": "Qwen3.5-9B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf",
        "size": "~5.2 GB",
        "type": "小众",
        "mirror_recommended": False
    },
    {
        "id": 4,
        "name": "NemoMix 12B",
        "repo": "bartowski/NemoMix-Unleashed-12B-GGUF",
        "file": "NemoMix-Unleashed-12B-Q4_K_M.gguf",
        "size": "~7.0 GB",
        "type": "热门",
        "mirror_recommended": True
    },
    {
        "id": 5,
        "name": "Dolphin 2.9 Llama 3 8B",
        "repo": "bartowski/dolphin-2.9-llama3-8b-GGUF",
        "file": "dolphin-2.9-llama3-8b-Q4_K_M.gguf",
        "size": "~4.9 GB",
        "type": "热门",
        "mirror_recommended": True
    },
    {
        "id": 6,
        "name": "Phi-3.5 Mini 3.8B",
        "repo": "bartowski/Phi-3.5-mini-instruct-GGUF",
        "file": "Phi-3.5-mini-instruct-Q4_K_M.gguf",
        "size": "~2.2 GB",
        "type": "热门",
        "mirror_recommended": True
    },
]

# 下载源
sources = [
    {
        "name": "HuggingFace原始",
        "base_url": "https://huggingface.co/{repo}/resolve/main/{file}",
        "description": "官方源，可能较慢"
    },
    {
        "name": "HF Mirror",
        "base_url": "https://hf-mirror.com/{repo}/resolve/main/{file}",
        "description": "国内镜像，可能较快"
    },
]

def test_url(name, url, timeout=TIMEOUT):
    """测试URL是否可访问，返回速度信息"""
    print(f"    测试 {name}...", end=" ", flush=True)
    
    try:
        start = time.time()
        req = urllib.request.Request(url, method='HEAD')
        req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        
        with urllib.request.urlopen(req, timeout=timeout) as response:
            status = response.status
            elapsed = time.time() - start
            content_length = response.headers.get('Content-Length', 'Unknown')
            
            if status == 200:
                print(f"✅ 成功 ({elapsed:.2f}s)")
                if content_length != 'Unknown':
                    size_mb = int(content_length) / 1024 / 1024
                    print(f"       文件大小: {size_mb:.2f} MB")
                return {
                    "success": True,
                    "time": elapsed,
                    "status": status,
                    "size": content_length
                }
            else:
                print(f"⚠️  状态码: {status}")
                return {
                    "success": False,
                    "time": elapsed,
                    "status": status,
                    "error": f"HTTP {status}"
                }
                
    except urllib.error.URLError as e:
        error_msg = str(e.reason) if hasattr(e, 'reason') else str(e)
        print(f"❌ 失败: {error_msg}")
        return {
            "success": False,
            "error": error_msg
        }
    except Exception as e:
        error_msg = str(e)
        print(f"❌ 失败: {error_msg}")
        return {
            "success": False,
            "error": error_msg
        }

def main():
    print("=" * 80)
    print("🔍 模型下载速度测试工具")
    print("=" * 80)
    print()
    print(f"超时设置: {TIMEOUT}秒")
    print()
    
    # 检查网络
    print("检查网络连接...")
    try:
        req = urllib.request.Request("https://www.baidu.com", method='HEAD')
        urllib.request.urlopen(req, timeout=5)
        print("✅ 网络正常")
    except:
        print("❌ 网络可能有问题，但继续测试...")
    print()
    
    all_results = []
    
    for model in models:
        print(f"\n{'─' * 80}")
        print(f"[{model['id']}] {model['name']}")
        print(f"    📦 大小: {model['size']} | 🏷️ 类型: {model['type']}")
        if model['mirror_recommended']:
            print(f"    💡 推荐使用镜像加速")
        print()
        
        model_results = {
            "model": model,
            "sources": {}
        }
        
        for source in sources:
            url = source['base_url'].format(repo=model['repo'], file=model['file'])
            print(f"  {source['name']}:")
            result = test_url(source['name'], url)
            model_results["sources"][source['name']] = result
            all_results.append({
                "model_name": model['name'],
                "model_type": model['type'],
                "source": source['name'],
                "result": result
            })
            time.sleep(1)  # 避免请求过快
        
        # 总结
        successes = [r for r in model_results["sources"].values() if r.get("success")]
        if successes:
            best = min(successes, key=lambda x: x.get("time", float('inf')))
            print(f"\n  🏆 最快: {list(model_results['sources'].keys())[list(model_results['sources'].values()).index(best)]} ({best.get('time', 'N/A'):.2f}s)")
    
    # 汇总报告
    print("\n" + "=" * 80)
    print("📊 测试结果汇总")
    print("=" * 80)
    
    print("\n【HuggingFace 原始源】")
    hf_original = [r for r in all_results if r['source'] == 'HuggingFace原始']
    hf_success = [r for r in hf_original if r['result'].get('success')]
    hf_failed = [r for r in hf_original if not r['result'].get('success')]
    print(f"  ✅ 成功: {len(hf_success)}/6")
    print(f"  ❌ 失败: {len(hf_failed)}/6")
    if hf_success:
        avg_time = sum(r['result'].get('time', 0) for r in hf_success) / len(hf_success)
        print(f"  平均连接时间: {avg_time:.2f}s")
    
    print("\n【HF Mirror 镜像源】")
    hf_mirror = [r for r in all_results if r['source'] == 'HF Mirror']
    mirror_success = [r for r in hf_mirror if r['result'].get('success')]
    mirror_failed = [r for r in hf_mirror if not r['result'].get('success')]
    print(f"  ✅ 成功: {len(mirror_success)}/6")
    print(f"  ❌ 失败: {len(mirror_failed)}/6")
    if mirror_success:
        avg_time = sum(r['result'].get('time', 0) for r in mirror_success) / len(mirror_success)
        print(f"  平均连接时间: {avg_time:.2f}s")
    
    print("\n" + "=" * 80)
    print("💡 优化建议")
    print("=" * 80)
    print()
    print("根据测试结果，推荐以下下载策略：")
    print()
    
    # 分析每个模型
    for model in models:
        hf_ok = any(r['result'].get('success') for r in all_results 
                   if r['model_name'] == model['name'] and r['source'] == 'HuggingFace原始')
        mirror_ok = any(r['result'].get('success') for r in all_results 
                       if r['model_name'] == model['name'] and r['source'] == 'HF Mirror')
        
        if hf_ok and mirror_ok:
            # 两者都通，比较速度
            hf_time = next((r['result']['time'] for r in all_results 
                           if r['model_name'] == model['name'] and r['source'] == 'HuggingFace原始'), float('inf'))
            mirror_time = next((r['result']['time'] for r in all_results 
                               if r['model_name'] == model['name'] and r['source'] == 'HF Mirror'), float('inf'))
            
            if mirror_time < hf_time:
                print(f"  ✅ {model['name']}: 推荐使用 HF Mirror (速度快 {hf_time/mirror_time:.1f}x)")
            else:
                print(f"  ✅ {model['name']}: 推荐使用 原始URL (速度快 {mirror_time/hf_time:.1f}x)")
        elif hf_ok:
            print(f"  ⚠️  {model['name']}: 仅原始URL可用")
        elif mirror_ok:
            print(f"  ⚠️  {model['name']}: 仅HF Mirror可用")
        else:
            print(f"  ❌ {model['name']}: 两个源都不可用（网络问题或需要代理）")
    
    print()
    print("=" * 80)
    print("📝 注意事项")
    print("=" * 80)
    print()
    print("1. 如果测试全部失败，请检查网络代理设置")
    print("2. 小众仓库（llmfan46, HauhauCS）可能镜像未同步")
    print("3. 可以手动从浏览器下载模型，放到 Shared/models/ 目录")
    print("4. 脚本支持断点续传，中断后可重新运行继续下载")
    print()

if __name__ == "__main__":
    main()
