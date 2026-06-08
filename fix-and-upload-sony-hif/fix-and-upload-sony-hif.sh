#!/bin/zsh

# 1. 預設處理目前資料夾，亦可透過參數指定路徑
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 錯誤: 目錄 $TARGET_DIR 不存在。"
    exit 1
fi

# 2. 自動將路徑轉換為標準的「絕對路徑」
ABS_PATH=$(cd "$TARGET_DIR" && pwd)

# 3. 檢查當前目錄是否存在設定檔
if [ ! -f "./config.hjson" ]; then
    echo "❌ 錯誤: 找不到 ./config.hjson 設定檔，請確保檔案存在。"
    exit 1
fi

echo "🔄 [1/3] 自動同步設定檔：將 config.hjson 內 SourceFolder 強制變更為 -> $ABS_PATH"
# 💡 修正核心：匹配不論是 source 還是 SourceFolder，統一強制覆寫為符合官方規範的 SourceFolder
perl -pi -e "s|^\s*\"?source(Folder)?\"?\s*[:=].*|      SourceFolder: \"$ABS_PATH\"|i" config.hjson

echo "🚀 [2/3] 正在遞迴修正子資料夾內所有 Sony HIF/HEIC 相片方向屬性..."
/opt/homebrew/bin/exiftool -r -if '$filename !~ /^\._/' "-Orientation<CameraOrientation" -overwrite_original -q -q -ext hif -ext HIF -ext heic -ext HEIC "$ABS_PATH"

echo "✅ 所有子資料夾內的方向修正完成！"
echo "🚚 [3/3] 正在同步上傳至 Google Photos..."

# 4. 執行同步上傳
gphotos-uploader-cli push --config .

echo "🎉 所有流程處理完畢！"