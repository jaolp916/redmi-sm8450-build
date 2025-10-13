#!/bin/bash
set -e

# 检查是否提供了设备代号
if [ -z "$1" ]; then
    echo "错误: 请提供设备代号作为参数"
    echo "用法: $0 <device_codename>"
    exit 1
fi

DEVICE_CODENAME="$1"
echo "开始为设备 $DEVICE_CODENAME 编译组件..."

# 设备配置 - 针对红米SM8450设备
case $DEVICE_CODENAME in
    rubens)
        # Redmi K50 Ultra 配置
        BUILD_TARGET="lineage_rubens-userdebug"
        VENDOR_NAME="xiaomi"
        ;;
    # 可添加其他设备配置
    *)
        echo "错误: 不支持的设备代号 $DEVICE_CODENAME"
        exit 1
        ;;
esac

# 初始化编译环境
echo "初始化编译环境..."
source build/envsetup.sh
lunch $BUILD_TARGET

# 编译vendor
echo "开始编译vendor..."
make vendorimage -j$(nproc --all)

# 检查编译结果
if [ ! -f "out/target/product/$DEVICE_CODENAME/vendor.img" ]; then
    echo "错误: vendor.img 编译失败!"
    exit 1
fi

# 编译vendor_dlkm
echo "开始编译vendor_dlkm..."
make vendor_dlkmimage -j$(nproc --all)

if [ ! -f "out/target/product/$DEVICE_CODENAME/vendor_dlkm.img" ]; then
    echo "错误: vendor_dlkm.img 编译失败!"
    exit 1
fi

# 编译dtb
echo "开始编译dtb..."
make dtb -j$(nproc --all)

if [ ! -f "out/target/product/$DEVICE_CODENAME/dtb.img" ]; then
    echo "错误: dtb.img 编译失败!"
    exit 1
fi

# 编译dtbo
echo "开始编译dtbo..."
make dtboimg -j$(nproc --all)

if [ ! -f "out/target/product/$DEVICE_CODENAME/dtbo.img" ]; then
    echo "错误: dtbo.img 编译失败!"
    exit 1
fi

# 输出编译成功信息
echo "所有组件编译成功!"
echo "输出文件位置:"
ls -lh out/target/product/$DEVICE_CODENAME/{vendor.img,vendor_dlkm.img,dtb.img,dtbo.img}
