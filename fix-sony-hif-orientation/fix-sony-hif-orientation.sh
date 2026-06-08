#!/bin/zsh

# 預設處理目前執行指令的資料夾，亦可透過參數指定路徑
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 錯誤: 目錄 $TARGET_DIR 不存在。"
    exit 1
fi

echo "🚀 正在遞迴修正資料夾內所有 Sony HIF/HEIC 相片方向屬性..."

# 1. 加入 -r 支援子資料夾遞迴掃描
# 2. 將原本固定的 "." 替換為變數 "$TARGET_DIR"
/opt/homebrew/bin/exiftool -r -if '$filename !~ /^\._/' "-Orientation<CameraOrientation" -overwrite_original -q -q -ext hif -ext HIF -ext heic -ext HEIC "$TARGET_DIR"

echo "✅ 處理完畢！"