#!/bin/bash
set -e  # 出错立即退出

# 补丁目录（与工作流中一致）
PATCH_DIR="$GITHUB_WORKSPACE/patches/dtb-patch"
# 内核/设备树源码目录（根据你的编译环境调整）
SRC_DIR="/mnt/android/redmi"  # 完整源码环境路径（若用极简环境则改为/mnt/build/kernel）

# 检查目录是否存在
if [ ! -d "$PATCH_DIR" ]; then
    echo "❌ 补丁目录 $PATCH_DIR 不存在！"
    exit 1
fi
if [ ! -d "$SRC_DIR" ]; then
    echo "❌ 源码目录 $SRC_DIR 不存在！"
    exit 1
fi

# 应用所有补丁（按顺序）
echo "=== 开始应用所有设备树补丁 ==="
for patch in "$PATCH_DIR"/*.patch; do
    if [ -f "$patch" ]; then
        echo "应用补丁：$(basename "$patch")"
        # 进入源码目录应用补丁
        (cd "$SRC_DIR" && git apply "$patch") || {
            echo "❌ 补丁 $(basename "$patch") 应用失败！"
            exit 1
        }
    fi
done

echo "✅ 所有补丁应用成功！"
