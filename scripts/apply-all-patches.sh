#!/bin/bash
set -euo pipefail

# 明确指定补丁目录（与工作流中一致，基于仓库根目录）
PATCH_DIR="$GITHUB_WORKSPACE/patches/dtb-patch"
KERNEL_DIR="/mnt/build/kernel"

# 二次检查补丁目录（即使工作流通过，脚本内再确认一次）
if [ ! -d "$PATCH_DIR" ]; then
  echo "❌ 脚本内错误：补丁目录 $PATCH_DIR 不存在！"
  echo "请检查仓库目录结构是否为：仓库根目录/patches/dtb-patch/"
  exit 1
fi

# 检查内核目录
if [ ! -d "$KERNEL_DIR" ]; then
  echo "❌ 脚本内错误：内核目录 $KERNEL_DIR 不存在！"
  exit 1
fi

# 应用补丁
echo "=== 开始应用补丁（来自 $PATCH_DIR） ==="
for patch in "$PATCH_DIR"/*.patch; do
  if [ -f "$patch" ]; then
    patch_name=$(basename "$patch")
    echo "应用：$patch_name"
    git -C "$KERNEL_DIR" apply "$patch" || {
      echo "❌ 补丁 $patch_name 应用失败！可能原因："
      echo "1. 补丁与内核版本不匹配（请检查内核分支是否正确）"
      echo "2. 补丁路径错误（实际路径：$patch）"
      exit 1
    }
  fi
done

echo "✅ 所有补丁应用成功"
