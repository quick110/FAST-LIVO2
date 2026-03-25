#!/bin/bash
# 修改日志：2026-03-25 - 修复 Livox 驱动安装错误，改为源码编译模式
# 作者: @LJC

set -e

echo "--- [1/5] 配置 ROS Noetic 官方源与公钥 ---"
sudo apt-get update && sudo apt-get install -y curl gnupg2
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-get update

echo "--- [2/5] 安装 ROS 核心组件与依赖 ---"
# 去掉了报错的 livox-ros-driver，改为安装基础版
sudo apt-get install -y ros-noetic-desktop-full \
    libpcl-dev libgoogle-glog-dev libgflags-dev \
    libatlas-base-dev libsuitesparse-dev \
    python3-catkin-tools python3-rosdep cmake g++

echo "--- [3/5] 源码编译 Livox-SDK (底层支持) ---"
if [ ! -d "/tmp/Livox-SDK" ]; then
    git clone https://github.com/Livox-SDK/Livox-SDK.git /tmp/Livox-SDK
    cd /tmp/Livox-SDK/build && cmake .. && make -j$(nproc)
    sudo make install
    cd -
fi

echo "--- [4/5] 准备工作空间并克隆 livox_ros_driver (解决报错) ---"
source /opt/ros/noetic/setup.bash
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src

# 关键：手动下载 livox_ros_driver 源码
if [ ! -d "livox_ros_driver" ]; then
    git clone https://github.com/Livox-SDK/livox_ros_driver.git
fi

# 链接你的 FAST-LIVO2 项目
[ ! -d "FAST-LIVO2" ] && ln -s /workspaces/FAST-LIVO2 .

echo "--- [5/5] 组件完整性检查与初步编译 ---"
printf "\n@LJC 环境自检报告：\n"
[ -f "/usr/local/include/livox_sdk.h" ] && echo "✅ Livox-SDK: 源码安装成功" || echo "❌ Livox-SDK: 缺失"
command -v rosversion &> /dev/null && echo "✅ ROS Noetic: 已就绪" || echo "❌ ROS: 缺失"

echo "正在尝试编译工作空间（含驱动 + 算法）..."
cd ~/catkin_ws
catkin_make -j$(nproc)

echo "--- 脚本执行完毕 | 作者: @LJC ---"