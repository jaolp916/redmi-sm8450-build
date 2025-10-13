#!/bin/bash
set -e  # 出错立即退出

# 校验参数（设备代号+编译类型）
if [ $# -ne 2 ]; then
    echo "Usage: $0 <device_codename> <build_type>"
    echo "Example: $0 rubens userdebug"
    exit 1
fi

DEVICE=$1
BUILD_TYPE=$2
BUILD_TARGET="${DEVICE}-${BUILD_TYPE}"

# 初始化编译环境
echo "=== Initializing build environment for $BUILD_TARGET ==="
source build/envsetup.sh
lunch $BUILD_TARGET

# 编译vendor（解决文件加载异常）
echo -e "\n=== Building vendor.img ==="
make vendorimage -j$(nproc --all)
if [ ! -f "out/target/product/$DEVICE/vendor.img" ]; then
    echo "❌ Error: vendor.img build failed!"
    exit 1
fi

# 编译vendor_dlkm（解决显示异常）
echo -e "\n=== Building vendor_dlkm.img ==="
make vendor_dlkmimage -j$(nproc --all)
if [ ! -f "out/target/product/$DEVICE/vendor_dlkm.img" ]; then
    echo "❌ Error: vendor_dlkm.img build failed!"
    exit 1
fi

# 编译dtb（解锁分区）
echo -e "\n=== Building dtb.img ==="
make dtb -j$(nproc --all)
if [ ! -f "out/target/product/$DEVICE/dtb.img" ]; then
    echo "❌ Error: dtb.img build failed!"
    exit 1
fi

# 编译dtbo（解锁电池容量）
echo -e "\n=== Building dtbo.img ==="
make dtboimg -j$(nproc --all)
if [ ! -f "out/target/product/$DEVICE/dtbo.img" ]; then
    echo "❌ Error: dtbo.img build failed!"
    exit 1
fi

# 编译成功
echo -e "\n✅ All components built successfully!"
echo "Products path: out/target/product/$DEVICE/"
ls -lh out/target/product/$DEVICE/{vendor.img,vendor_dlkm.img,dtb.img,dtbo.img}
