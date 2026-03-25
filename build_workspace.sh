#!/bin/bash
# 修改日志：2026-03-25 - 修复 Codespaces 下 zsh/bash 环境导致 setup.bash 路径解析错误的问题，集成全自动编译流程
# 作者: @LJC

set -e # 遇到错误立即停止

echo "=== [1/4] 环境诊断与清理 ==="
echo "[调试] 当前执行脚本的解释器: $BASH_VERSION"
WORKSPACE_DIR="$HOME/catkin_ws"

if [ -d "$WORKSPACE_DIR/build" ]; then
    echo "[调试] 检测到旧的构建缓存，正在清理 build/ 和 devel/ 目录..."
    rm -rf "$WORKSPACE_DIR/build" "$WORKSPACE_DIR/devel"
fi

echo "=== [2/4] 修复并加载 ROS 环境变量 ==="
# 因为脚本头部指定了 #!/bin/bash，这里加载 setup.bash 是绝对安全的
if [ -f "/opt/ros/noetic/setup.bash" ]; then
    echo "[调试] 加载系统级 ROS Noetic 基础环境..."
    source /opt/ros/noetic/setup.bash
else
    echo "[错误] 找不到 /opt/ros/noetic/setup.bash，请确认 ROS 安装状态。"
    exit 1
fi

echo "=== [3/4] 执行 Catkin 编译 (FAST-LIVO2 & 依赖) ==="
cd "$WORKSPACE_DIR"
echo "[调试] 开始编译工作空间 (使用 2 个线程防止 Codespaces 内存溢出)..."
catkin_make -j2

echo "=== [4/4] Codespaces 终端环境持久化配置 ==="
# 针对你的 Zsh 终端，写入正确的 .zshrc 配置
ZSHRC_FILE="$HOME/.zshrc"

if ! grep -q "source /opt/ros/noetic/setup.zsh" "$ZSHRC_FILE" 2>/dev/null; then
    echo "source /opt/ros/noetic/setup.zsh" >> "$ZSHRC_FILE"
    echo "[调试] 已将系统 ROS 环境 (zsh版) 注入到 ~/.zshrc"
fi

if [ -f "$WORKSPACE_DIR/devel/setup.zsh" ]; then
    if ! grep -q "source $WORKSPACE_DIR/devel/setup.zsh" "$ZSHRC_FILE" 2>/dev/null; then
        echo "source $WORKSPACE_DIR/devel/setup.zsh" >> "$ZSHRC_FILE"
        echo "[调试] 已将工作空间环境 (zsh版) 注入到 ~/.zshrc"
    fi
fi

echo "---------------------------------------------------"
echo "✅ 编译流程执行完毕！目标文件已生成。"
echo "⚠️  最后一步：请在终端输入 'source ~/.zshrc' 刷新你当前的界面。"
echo "作者: @LJC"