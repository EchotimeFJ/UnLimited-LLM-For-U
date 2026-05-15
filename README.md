# UnLimited-LLM-For-U 🚀

**本地AI模型运行工具** - 专为国内用户优化，支持断点续传和镜像加速下载

[![Star](https://img.shields.io/github/stars/EchotimeFJ/UnLimited-LLM-For-U?style=social)](https://github.com/EchotimeFJ/UnLimited-LLM-For-U)
[![License](https://img.shields.io/github/license/EchotimeFJ/UnLimited-LLM-For-U)](LICENSE)

---

## ✨ 核心特性

### 🔥 国内优化版
- ✅ **HuggingFace镜像加速** - hf-mirror.com 国内CDN
- ✅ **多源智能切换** - 自动尝试最快下载源
- ✅ **断点续传下载** - 网络中断后可继续
- ✅ **自动重试机制** - 最多5次重试确保成功

### 🎯 核心功能
- 📦 开箱即用 - 便携式Python环境，无需安装
- 🔄 跨平台支持 - Windows / macOS / Linux / Android
- 💾 模型复用 - 一套模型，多平台使用
- 🌐 本地部署 - 完全离线运行，保护隐私
- 📱 局域网访问 - 手机电脑同一网络即可使用

---

## 💻 系统要求

| 项目 | 最低配置 | 推荐配置 |
|------|---------|---------|
| 存储空间 | 8 GB | 16 GB+ |
| 内存 | 8 GB | 16 GB+ |
| 操作系统 | Windows 10 / macOS 10.15 / Ubuntu 20.04 | 最新版本 |

---

## 📁 项目结构

```
UnLimited-LLM-For-U/
├── 📁 Windows/          # Windows安装和启动脚本
│   ├── install.bat     # 安装脚本（含镜像加速）
│   └── start.bat       # 启动脚本
├── 📁 Linux/           # Linux安装和启动脚本
│   ├── install.sh      # 安装脚本
│   └── start.sh        # 启动脚本
├── 📁 Mac/             # macOS安装和启动脚本
├── 📁 Android/         # Android (Termux) 脚本
└── 📁 Shared/          # 共享数据目录
    ├── 📁 bin/         # 引擎文件
    ├── 📁 models/      # AI模型文件
    └── 📁 chat_data/  # 聊天记录
```

---

## 📦 可用模型

本项目提供6个预置AI模型，支持断点续传和镜像加速下载：

| # | 模型名称 | 大小 | 内存需求 | 类型 | 推荐场景 |
|---|---------|------|---------|------|---------|
| 1 | **Gemma 2 2B Abliterated** | ~1.6 GB | 8 GB | 解除限制 | ⭐ 日常对话、快速响应（推荐） |
| 2 | **Gemma 4 E4B Ultra Uncensored Heretic** | ~5.3 GB | 16 GB | 解除限制 | 激进问答、无条件服从 |
| 3 | **Qwen 3.5 9B Uncensored Aggressive** | ~5.2 GB | 16 GB | 解除限制 | 国产之光、代码能力强 |
| 4 | **NemoMix Unleashed 12B** | ~7.0 GB | 16 GB+ | 解除限制 | 超大模型、最强理解力 |
| 5 | **Dolphin 2.9 Llama 3 8B** | ~4.9 GB | 12 GB | 解除限制 | Dolphin家族、中文优化 |
| 6 | **Phi-3.5 Mini 3.8B** | ~2.2 GB | 8 GB | 标准版 | 轻量高效、资源友好 |

### 📊 模型对比

| 模型 | 速度 | 智能度 | 内存占用 | 推荐指数 |
|------|------|--------|---------|---------|
| Gemma 2 2B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 低 | ⭐⭐⭐⭐⭐ |
| Gemma 4 4B | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 中 | ⭐⭐⭐⭐ |
| Qwen 3.5 9B | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 高 | ⭐⭐⭐⭐⭐ |
| NemoMix 12B | ⭐⭐ | ⭐⭐⭐⭐⭐ | 很高 | ⭐⭐⭐ |
| Dolphin 8B | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 中 | ⭐⭐⭐⭐ |
| Phi-3.5 3.8B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 低 | ⭐⭐⭐⭐ |

**建议首次使用选择 Gemma 2 2B 版本**，速度快，兼容性好。

---

## 🚀 快速开始

### Windows 系统

1. 下载本项目，解压到本地目录
2. 双击运行 `Windows/install.bat`
3. 选择要下载的AI模型（推荐选择1：Gemma 2 2B）
4. 等待下载完成（使用国内镜像，速度更快）
5. 双击运行 `Windows/start.bat`
6. 浏览器自动打开聊天界面

### Linux 系统

```bash
# 克隆项目
git clone https://github.com/EchotimeFJ/UnLimited-LLM-For-U.git
cd UnLimited-LLM-For-U/Linux

# 运行安装脚本
bash install.sh

# 启动AI
bash start.sh
```

### macOS 系统

```bash
# 克隆项目
git clone https://github.com/EchotimeFJ/UnLimited-LLM-For-U.git
cd UnLimited-LLM-For-U/Mac

# 运行安装脚本
chmod +x install.command
./install.command

# 启动AI
chmod +x start.command
./start.command
```

### Android 系统（Termux）

1. 从 [F-Droid](https://f-droid.org/) 安装 Termux（不要用Play商店版本）
2. 打开Termux，克隆项目：
   ```bash
   pkg update && pkg upgrade
   git clone https://github.com/EchotimeFJ/UnLimited-LLM-For-U.git
   cd UnLimited-LLM-For-U/Android
   ```
3. 运行安装：
   ```bash
   bash install.sh
   ```
4. 启动AI：
   ```bash
   bash start.sh
   ```
5. 建议先运行 `termux-wake-lock` 防止进程被杀死

---

## 📱 局域网访问

启动AI后，可以在同一网络的其他设备上访问：

1. 查看终端显示的局域网地址（格式：`http://192.168.x.x:3333`）
2. 确保防火墙允许3333端口
3. 在手机/平板浏览器中输入该地址即可使用

**提示**：访问前请确保手机和电脑在同一WiFi网络下。

---

## 🔧 常见问题

### Q: 安装脚本下载很慢怎么办？
**A**: 脚本已内置HuggingFace镜像（hf-mirror.com），如仍慢，可手动设置：
```bash
# 设置环境变量
export HF_ENDPOINT=https://hf-mirror.com
```

### Q: 下载中断了怎么办？
**A**: 支持断点续传！重新运行安装脚本会自动继续上次未完成的下载。

### Q: Gemma 4 Heretic 下载特别慢？
**A**: 由于该模型存储在小众仓库，可能未被镜像全面同步。可尝试：
1. 多次重试（脚本会自动切换下载源）
2. 手动从浏览器下载后放入 `Shared/models/` 目录

### Q: 模型应该放在哪里？
**A**: 下载的 `.gguf` 模型文件应放在 `Shared/models/` 目录下。

### Q: 如何查看已安装的模型？
**A**: 启动后访问 http://localhost:3333 可以在界面中查看和管理模型。

### Q: Windows上脚本闪退怎么办？
**A**: 右键点击脚本，选择"用PowerShell打开"或"用命令提示符打开"。

### Q: Linux启动报错 "权限不足"？
**A**: 请给脚本添加执行权限：
```bash
chmod +x install.sh start.sh
```

### Q: 如何下载其他模型？
**A**: 在安装时选择 `[C] CUSTOM`，然后粘贴HuggingFace上的GGUF模型链接。

---

## 🔌 自定义模型

如果你想使用其他模型：

1. 访问 [HuggingFace GGUF模型库](https://huggingface.co/models?other=gguf)
2. 下载 `.gguf` 格式的模型文件
3. 将文件放入 `Shared/models/` 目录
4. 重启AI即可识别新模型

---

## 📊 性能对比

| 运行环境 | Token生成速度 | 适用模型 |
|---------|-------------|---------|
| PC + GPU (NVIDIA) | 30-50 tok/s | 7B+ 模型 |
| PC + GPU (Apple M系列) | 20-40 tok/s | 7B+ 模型 |
| PC + CPU (高性能) | 5-15 tok/s | 2B-4B 模型 |
| Android (8GB+) | 3-10 tok/s | 2B 模型 |

---

## 🛠️ 技术架构

```
┌─────────────────────────────────────────┐
│           前端界面 (Web UI)              │
│    http://localhost:3333 (Dark Mode)    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│        Python HTTP 服务器               │
│    - RESTful API                       │
│    - WebSocket 流式输出                 │
│    - 跨平台兼容性                       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│        Ollama 推理引擎                  │
│    - GGUF模型加载                       │
│    - CUDA/Metal/CPU加速                │
│    - 内存优化管理                       │
└─────────────────────────────────────────┘
```

---

## 🙏 致谢

- 原始项目：[USB-Uncensored-LLM](https://github.com/techjarves/USB-Uncensored-LLM)
- Ollama引擎：[ollama/ollama](https://github.com/ollama/ollama)
- 模型镜像：[HF-Mirror](https://hf-mirror.com)
- 模型来源：[HuggingFace GGUF Models](https://huggingface.co/models?other=gguf)

---

## 📄 许可证

本项目基于MIT许可证开源。

---

## ⚠️ 使用声明

本工具仅供技术研究和学习使用。请遵守当地法律法规，合理使用AI模型。
