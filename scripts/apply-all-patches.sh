#!/bin/bash
set -euo pipefail

# 补丁应用脚本：应用patches/dtb-patch目录下的所有补丁到内核源码
# 使用方法：chmod +x apply-all-patches.sh && ./apply-all-patches.sh

# 配置路径（与工作流中一致）
PATCH_DIR="$GITHUB_WORKSPACE/patches/dtb-patch"  # 补丁目录
KERNEL_DIR="/mnt/build/kernel"                   # 内核源码目录

# 检查补丁目录是否存在
if [ ! -d "$PATCH_DIR" ]; then
  echo "❌ 错误：补丁目录 $PATCH_DIR 不存在！"
  exit 1
fi

# 检查内核目录是否存在
if [ ! -d "$KERNEL_DIR" ]; then
  echo "❌ 错误：内核源码目录 $KERNEL_DIR 不存在！"
  exit 1
fi

# 应用所有.patch文件（按文件名顺序）
echo "=== 开始应用设备树补丁 ==="
patch_count=0
for patch_file in "$PATCH_DIR"/*.patch; do
  # 跳过非文件（如目录）
  if [ -f "$patch_file" ]; then
    patch_name=$(basename "$patch_file")
    echo "应用补丁：$patch_name"
    # 进入内核目录应用补丁
    git -C "$KERNEL_DIR" apply "$patch_file" || {
      echo "❌ 补丁 $patch_name 应用失败！请检查补丁与内核版本是否匹配。"
      exit 1
    }
    patch_count=$((patch_count + 1))
  fi
done

if [ $patch_count -eq 0 ]; then
  echo "⚠️ 警告：未找到任何.patch文件（路径：$PATCH_DIR）"
else
  echo "✅ 成功应用 $patch_count 个补丁"
fi
    
