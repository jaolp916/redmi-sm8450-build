#!/bin/bash
set -e

# 此脚本用于本地开发时同步源码

# 检查是否提供了设备代号
if [ -z "$1" ]; then
    echo "错误: 请提供设备代号作为参数"
    echo "用法: $0 <device_codename>"
    exit 1
fi

DEVICE_CODENAME="$1"
SRC_DIR="$HOME/android/redmi"

# 创建源码目录
mkdir -p $SRC_DIR
cd $SRC_DIR

# 检查是否已安装repo
if ! command -v repo &> /dev/null; then
    echo "安装repo工具..."
    curl https://storage.googleapis.com/git-repo-downloads/repo > repo
    chmod a+x repo
    sudo mv repo /usr/local/bin/
fi

# 初始化源码仓库（以LineageOS 20为例）
if [ ! -d ".repo" ]; then
    echo "初始化源码仓库..."
    repo init -u https://github.com/LineageOS/android.git -b lineage-20.0
fi

# 复制设备特定清单
echo "应用设备特定清单..."
mkdir -p .repo/local_manifests
cp $(dirname "$0")/../local_manifests/redmi-sm8450.xml .repo/local_manifests/

# 同步源码
echo "开始同步源码..."
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)

echo "源码同步完成，位于 $SRC_DIR"
