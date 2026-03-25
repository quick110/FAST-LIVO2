#!/bin/bash
# 修改日志：2026-03-25 - 修复 vikit_common 与 FAST-LIVO2 接口不兼容问题，适配 OpenCV 4
# 作者: @LJC

set -e

WORKSPACE_DIR="/home/vscode/catkin_ws"
VIKIT_SRC="$WORKSPACE_DIR/src/rpg_vikit/vikit_common"

echo "=== [1/3] 修复 OpenCV 4 宏兼容性 (@LJC) ==="
# 替换 CV_INTER_LINEAR 为 cv::INTER_LINEAR
sed -i 's/CV_INTER_LINEAR/cv::INTER_LINEAR/g' $VIKIT_SRC/src/pinhole_camera.cpp
# 替换 CV_RANSAC 为 cv::RANSAC
sed -i 's/CV_RANSAC/cv::RANSAC/g' $VIKIT_SRC/src/homography.cpp
# 额外预防：替换 CV_LOAD_IMAGE_GRAYSCALE 等常见宏
sed -i 's/CV_LOAD_IMAGE_/cv::IMREAD_/g' $VIKIT_SRC/src/vision.cpp 2>/dev/null || true
sed -i 's/CV_RGB2GRAY/cv::COLOR_RGB2GRAY/g' $VIKIT_SRC/src/vision.cpp 2>/dev/null || true

echo "=== [2/3] 补充 AbstractCamera 接口以适配 FAST-LIVO2 (@LJC) ==="
# FAST-LIVO2 强行调用了基类中没有的函数，我们在基类中添加虚函数声明
HEADER_FILE="$VIKIT_SRC/include/vikit/abstract_camera.h"

# 检查是否已经添加过，防止重复添加
if ! grep -q "virtual double fx" "$HEADER_FILE"; then
    echo "正在向 abstract_camera.h 注入缺失的接口声明..."
    
    # 使用 sed 在 public: 下面插入虚函数声明
    sed -i '/public:/a \
  // @LJC Start: 2026-03-25 补充 FAST-LIVO2 所需的相机参数获取接口\
  virtual double fx() const { return 0.0; }\
  virtual double fy() const { return 0.0; }\
  virtual double cx() const { return 0.0; }\
  virtual double cy() const { return 0.0; }\
  virtual double scale() const { return 1.0; }\
  // @LJC End' "$HEADER_FILE"
fi

echo "=== [3/3] 继续编译工作空间 ==="
cd $WORKSPACE_DIR
# 重新编译，应该可以跨过之前的错误了
./build_workspace.sh