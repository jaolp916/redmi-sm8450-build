#!/bin/bash
set -e

# 检查参数
if [ $# -ne 2 ]; then
    echo "用法: $0 <设备代号> <编译类型>"
    exit 1
fi

DEVICE=$1
BUILD_TYPE=$2
BUILD_TARGET="${DEVICE}-${BUILD_TYPE}"

# 初始化编译环境
echo "初始化编译环境 for $BUILD_TARGET..."
source build/envsetup.sh
lunch $BUILD_TARGET

# 编译vendor
echo "开始编译vendor..."
make vendorimage -j$(nproc --all)

# 编译vendor_dlkm
echo "开始编译vendor_dlkm..."
make vendor_dlkmimage -j$(nproc --all)

# 编译dtb
echo "开始编译dtb..."
make dtb -j$(nproc --all)

# 编译dtbo
echo "开始编译dtbo..."
make dtboimg -j$(nproc --all)

# 验证编译结果
echo "验证编译结果..."
REQUIRED_FILES=(
    "out/target/product/$DEVICE/vendor.img"
    "out/target/product/$DEVICE/vendor_dlkm.img"
    "out/target/product/$DEVICE/dtb.img"
    "out/target/product/$DEVICE/dtbo.img"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "错误: 编译产物 $file 不存在!"
        exit 1
    fi
done

echo "所有组件编译成功!"
