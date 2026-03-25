#!/bin/bash
# 修改日志：2026-03-25 - 修复 Sophus 历史节点，采用官方明确指定的 a621ff 节点（非模板版）
# 作者: @LJC

set -e

echo "=== [1/5] 清理环境与错误残余 ==="
cd ~
rm -rf Sophus sophus_old.zip Sophus-*

echo "=== [2/5] 使用 Git 克隆并切换到官方非模板版 (a621ff) ==="
echo "[调试] 正在从官方仓库克隆并执行 checkout a621ff..."
git clone https://github.com/strasdat/Sophus.git
cd Sophus
git checkout a621ff

echo "=== [3/5] 注入 Eigen 3.3 兼容补丁 (@LJC) ==="
# 修复旧代码在 Ubuntu 20.04 上的 unit_complex_ 赋值报错 (lvalue required)
echo "[调试] 正在修改 so2.cpp 修复 lvalue required 报错..."
sed -i 's/unit_complex_.real() = 1.;/unit_complex_.real(1.);/g' sophus/so2.cpp
sed -i 's/unit_complex_.imag() = 0.;/unit_complex_.imag(0.);/g' sophus/so2.cpp

echo "=== [4/5] 编译并安装非模板版 Sophus ==="
# 依赖 20.04 默认的 CMake 即可
mkdir -p build && cd build
cmake ..
make -j2
sudo make install

echo "=== [5/5] 回到工作空间，继续编译 FAST-LIVO2 ==="
cd /workspaces/FAST-LIVO2
echo "[调试] 底层数学库安装完毕，启动工作空间全量编译..."
./build_workspace.sh