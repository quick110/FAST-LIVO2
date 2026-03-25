# --- 修改开始 ---
# 修改日志：2026-03-25 - 固化 FAST-LIVO2 编译环境，集成 ROS Noetic, Livox-SDK, 定制版 Sophus 及 Rosbridge
# 作者: @LJC

FROM mcr.microsoft.com/vscode/devcontainers/base:focal

# 避免 apt-get 交互式弹窗卡住自动构建
ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装基础依赖、ROS Noetic 及可视化通信组件 (Rosbridge)
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && apt-get update && apt-get install -y \
    ros-noetic-desktop-full \
    ros-noetic-rosbridge-suite \
    libpcl-dev libgoogle-glog-dev libgflags-dev \
    libatlas-base-dev libsuitesparse-dev \
    python3-catkin-tools python3-rosdep cmake g++ unzip wget \
    && rm -rf /var/lib/apt/lists/*

# 2. 源码编译并安装 Livox-SDK
RUN git clone https://github.com/Livox-SDK/Livox-SDK.git /tmp/Livox-SDK \
    && cd /tmp/Livox-SDK/build && cmake .. && make -j$(nproc) && make install \
    && rm -rf /tmp/Livox-SDK

# 3. 源码编译安装非模板版 Sophus (指定 a621ff 节点并打上 Eigen 3.3 补丁)
RUN git clone https://github.com/strasdat/Sophus.git /tmp/Sophus \
    && cd /tmp/Sophus && git checkout a621ff \
    && sed -i 's/unit_complex_.real() = 1.;/unit_complex_.real(1.);/g' sophus/so2.cpp \
    && sed -i 's/unit_complex_.imag() = 0.;/unit_complex_.imag(0.);/g' sophus/so2.cpp \
    && mkdir build && cd build && cmake .. && make -j$(nproc) && make install \
    && rm -rf /tmp/Sophus

# 4. 终端环境变量自动化配置
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/vscode/.bashrc \
    && echo "source /opt/ros/noetic/setup.zsh" >> /home/vscode/.zshrc

# --- 修改结束 ---