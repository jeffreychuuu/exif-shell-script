#!/bin/zsh

# 1. 接收參數 ($1 為路徑， $2 為選填的相簿名稱)
TARGET_DIR="${1:-.}"
ALBUM_INPUT="$2"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 錯誤: 目錄 $TARGET_DIR 不存在。"
    exit 1
fi

# 2. 自動將路徑轉換為標準的「絕對路徑」
ABS_PATH=$(cd "$TARGET_DIR" && pwd)

# 3. 檢查設定檔是否存在
if [ ! -f "./config.hjson" ]; then
    echo "❌ 錯誤: 找不到 ./config.hjson 設定檔，請確保檔案存在。"
    exit 1
fi

echo "🔄 [1/3] 自動同步設定檔..."

# 安全覆寫 SourceFolder 欄位（利用環境變數防範路徑斜線衝突）
TARGET_PATH="$ABS_PATH" perl -pi -e 's|^\s*\"?source(Folder)?\"?\s*[:=].*|      SourceFolder: "$ENV{TARGET_PATH}"|i' config.hjson

# 動態判斷並覆寫 Album 欄位
if [ -n "$ALBUM_INPUT" ]; then
    echo "   -> 相簿名稱強制變更為: name:$ALBUM_INPUT"
    ALBUM_VAL="name:$ALBUM_INPUT" perl -pi -e 's|^\s*\"?album\"?\s*[:=].*|      Album: "$ENV{ALBUM_VAL}"|i' config.hjson
else
    echo "   -> 未指定相簿參數，自動重設為子資料夾動態範本 (template:%_directory%)"
    ALBUM_VAL="template:%_directory%" perl -pi -e 's|^\s*\"?album\"?\s*[:=].*|      Album: "$ENV{ALBUM_VAL}"|i' config.hjson
fi

echo "🚀 [2/3] 正在遞迴修正子資料夾內所有 Sony HIF/HEIC 相片方向屬性..."
/opt/homebrew/bin/exiftool -r -if '$filename !~ /^\._/' "-Orientation<CameraOrientation" -overwrite_original -q -q -ext hif -ext HIF -ext heic -ext HEIC "$ABS_PATH"

echo "✅ 所有子資料夾內的方向修正完成！"
echo "🚚 [3/3] 正在同步上傳至 Google Photos..."

# 4. 執行同步上傳
gphotos-uploader-cli push --config .

echo "🎉 所有流程處理完畢！"