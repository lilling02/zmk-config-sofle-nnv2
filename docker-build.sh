#!/bin/bash
set -e

echo "=== Preparing workspace inside container ==="
mkdir -p /workspace
cd /workspace

if [ ! -d "/workspace/zmk" ]; then
  echo "=== Cloning ZMK firmware repository ==="
  git clone --depth 1 https://github.com/zmkfirmware/zmk.git
  cd zmk

  echo "=== Initializing west ==="
  west init -l app/
  echo "=== Updating west modules (this may take a few minutes) ==="
  west update
else
  echo "=== Using existing workspace ==="
  cd zmk
fi

echo "=== Exporting Zephyr ==="
west zephyr-export

echo "=== Building Left Shield ==="
west build -d build/left -p always -s app -b nice_nano -- -DSHIELD=sofle_left -DZMK_CONFIG="/config_host/config"

echo "=== Building Right Shield ==="
west build -d build/right -p always -s app -b nice_nano -- -DSHIELD=sofle_right -DZMK_CONFIG="/config_host/config"

echo "=== Copying UF2 files back to host ==="
mkdir -p /config_host/build
cp build/left/zephyr/zmk.uf2 /config_host/build/sofle_left-nice_nano_v2-zmk.uf2
cp build/right/zephyr/zmk.uf2 /config_host/build/sofle_right-nice_nano_v2-zmk.uf2

echo "=== Build Completed Successfully! ==="
