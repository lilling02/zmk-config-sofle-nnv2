# ZMK 固件编译与维护备忘指南

本指南记录了你的 Sofle Choc (nice!nano v2) 蓝牙分体键盘固件的本地目录结构、键位配置方法、编译命令以及如何将固件刷入键盘。

---

## 📂 目录结构与作用

在你的电脑上，ZMK 固件相关的文件主要存放在以下两个目录中：

### 1. 配置文件与输出目录：[C:\zmk-config](file:///C:/zmk-config)
这是你日常需要维护 Graves 目录，包含所有键位配置、自动编译脚本以及编译出来的固件成果。
*   **按键映射配置文件：** [sofle.keymap](file:///C:/zmk-config/config/sofle.keymap) —— **日常改键修改此文件即可**。
*   **功能启用配置文件：** [sofle.conf](file:///C:/zmk-config/config/sofle.conf) —— 用于开启/关闭屏幕、RGB 等全局配置。
*   **Docker 编译脚本：** [docker-build.sh](file:///C:/zmk-config/docker-build.sh) —— 固件打包的一键运行脚本。
*   **固件输出目录：** [C:\zmk-config\build](file:///C:/zmk-config/build) —— 编译完成后生成固件的文件夹：
    *   `sofle_left-nice_nano_v2-zmk.uf2`（左手固件）
    *   `sofle_right-nice_nano_v2-zmk.uf2`（右手固件）

### 2. 编译工具链与依赖区：[C:\zmk-workspace](file:///C:/zmk-workspace)
这是 Docker 编译时在容器内拉取的 **Zephyr RTOS 操作系统与 ZMK 源码依赖区**。
*   **容量大小：** 约 4.5 GB。
*   **作用：** 作为本地编译的**全局持久化缓存**，使你可以完全脱离 GitHub 离线编译固件，并且能够让下一次编译加速至 **5 - 10 秒** 内完成。请勿轻易删除此目录。

---

## 🛠️ 如何修改键位与重新编译

当你想要更改键盘的按键布局时，请按照以下步骤操作：

### 第一步：修改按键定义
你可以通过以下两种方式之一修改按键：

*   **直接修改本地代码**
    使用文本编辑器或 VS Code 打开本地文件： [sofle.keymap](file:///C:/zmk-config/config/sofle.keymap) ，直接修改对应层的按键代码。
*   **网页可视化修改**
    1. 打开官方的可视化工具：[ZMK Keymap Editor](https://nickcoutsos.github.io/keymap-editor/)。
    2. 导入你本地的 `sofle.keymap` 文件进行拖拽式修改。
    3. 修改完成后，将生成的新 `sofle.keymap` 覆盖保存到你的 [C:\zmk-config\config\sofle.keymap](file:///C:/zmk-config/config/sofle.keymap)。

### 第二步：一键执行编译
打开 Windows PowerShell，直接运行以下命令：

```powershell
docker run --rm -v "C:\zmk-config:/config_host" -v "C:\zmk-workspace:/workspace" zmkfirmware/zmk-build-arm:stable bash /config_host/docker-build.sh
```

> [!TIP]
> 编译由于使用了 `C:\zmk-workspace` 作为本地缓存，无需再次从 GitHub 拉取庞大的代码，通常 **5 到 15 秒内即可完成编译**。

---

## 📥 固件刷写步骤

> [!WARNING]
> **绝对不要在通电状态下连接左右手之间的 TRRS 弹簧线！** 蓝牙分体键盘通过蓝牙无线通信，插 TRRS 线强刷或通电极易烧毁 nice!nano 主控。请务必保持两边物理分离！

1.  **左手刷写**：
    *   使用 USB-C 数据线将**左手**主控连接到电脑。
    *   **快速双击** nice!nano 上的物理 Reset 按钮（或用镊子等金属物体快速双击短接 PCB 上主控旁边的 `RST` 和 `GND` 两孔）。
    *   此时电脑中会弹出一个类似于 U 盘的移动磁盘驱动器，名为 **`NICENANO`**。
    *   将编译生成的 [sofle_left-nice_nano_v2-zmk.uf2](file:///C:/zmk-config/build/sofle_left-nice_nano_v2-zmk.uf2) 文件直接拖入该磁盘中。拷贝完成后，磁盘会自动弹开，左手固件刷写完毕。
2.  **右手刷写**：
    *   拔掉左手，将**右手**主控通过 USB-C 连上电脑。
    *   同样**快速双击** Reset 按钮使其进入 U 盘模式（弹出 `NICENANO` 磁盘）。
    *   将 [sofle_right-nice_nano_v2-zmk.uf2](file:///C:/zmk-config/build/sofle_right-nice_nano_v2-zmk.uf2) 拖入，等待其自动写入并弹开。
3.  **连接使用**：
    *   拔掉数据线。
    *   给左右手接上锂电池（或通过充电宝、充电头分别供电），它们会自动进行无线配对。
    *   打开电脑蓝牙，搜索并连接到 **`Sofle`** 即可开始打字。

---

## ⚠️ 故障排查：蓝牙断连或左右手无法同步？

如果在长期使用中发现左右手断开连接，或者蓝牙无法重新配对，请在编译输出目录中找到 `settings_reset-nice_nano_v2-zmk.uf2`：
1. 分别给**左手**和**右手**双击进入 U 盘模式，刷入一遍 `settings_reset` 清理蓝牙硬件缓存。
2. 清理完后，重新按照上面的步骤分别刷入左手 and 右手固件，键盘将重新自动配对并恢复正常。
