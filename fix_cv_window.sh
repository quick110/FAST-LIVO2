#!/bin/bash
# 修改日志：2026-03-25 - 修复 vikit_common 中 img_align.cpp 的 OpenCV4 宏 CV_WINDOW_AUTOSIZE 兼容性问题
# 作者: @LJC

set -e

WORKSPACE_DIR="/home/vscode/catkin_ws"
FILE_TO_FIX="$WORKSPACE_DIR/src/rpg_vikit/vikit_common/src/img_align.cpp"

echo "=== [1/2] 注入 OpenCV 4 宏修复补丁 (@LJC) ==="
# 使用 sed 命令进行精准替换
sed -i 's/CV_WINDOW_AUTOSIZE/cv::WINDOW_AUTOSIZE/g' "$FILE_TO_FIX"
echo "已成功将 CV_WINDOW_AUTOSIZE 替换为 cv::WINDOW_AUTOSIZE。"

echo "=== [2/2] 继续执行工作空间编译 ==="
cd "$WORKSPACE_DIR"
# 重新唤起你的自动编译脚本
/workspaces/FAST-LIVO2/build_workspace.sh