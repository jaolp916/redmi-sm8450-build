#!/bin/bash
set -euo pipefail

PATCH_DIR="/home/runner/work/redmi-sm8450-build/redmi-sm8450-build/patches/dtb-patch"
# 关键：指定设备仓库目录（而非内核目录）
DEVICE_DIR="/mnt/build/device/xiaomi/diting"

# 验证设备仓库存在
if [ ! -d "$DEVICE_DIR" ]; then
  echo "❌ 设备仓库不存在：$DEVICE_DIR"
  exit 1
fi

# 验证目标文件确实存在于设备仓库
TARGET_FILE="$DEVICE_DIR/properties/system.prop"
if [ ! -f "$TARGET_FILE" ]; then
  echo "❌ 设备仓库中确实没有该文件：$TARGET_FILE"
  # 再次搜索设备仓库中的.prop文件
  find "$DEVICE_DIR" -name "*.prop"
  exit 1
fi

# 在设备仓库目录中应用补丁
echo "=== 开始在设备仓库中应用补丁 ==="
for patch in "$PATCH_DIR"/*.patch; do
  patch_name=$(basename "$patch")
  echo "应用：$patch_name"
  # 重要：在设备仓库目录中执行git apply
  git -C "$DEVICE_DIR" apply "$patch" || {
    echo "❌ 补丁 $patch_name 应用失败，尝试直接用patch命令"
    # 备用方案：使用patch命令强制应用（不依赖Git跟踪）
    cd "$DEVICE_DIR" && patch -p1 < "$patch"
  }
done
