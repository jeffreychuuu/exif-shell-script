#!/bin/zsh

# 1. 接收命令列參數 ($1: 目錄路徑, $2: 選填相簿名稱/auto)
TARGET_DIR="${1:-.}"
ALBUM_INPUT="$2"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 錯誤: 目錄 $TARGET_DIR 不存在。"
    exit 1
fi

echo "🚀 [1/2] 正在遞迴修正資料夾內所有 Sony HIF/HEIC 相片方向屬性..."
/opt/homebrew/bin/exiftool -r -if '$filename !~ /^\._/' "-Orientation<CameraOrientation" -overwrite_original -q -q -ext hif -ext HIF -ext heic -ext HEIC "$TARGET_DIR"
echo "✅ 方向修正完成！"

# ==========================================
# ─── Google Photos 核心整合區塊 ───
# ==========================================
if [ -n "$ALBUM_INPUT" ]; then
    # 💡 偵測收納於新架構子目錄內的設定檔
    if [ ! -f "./gphotos-config/config.hjson" ]; then
        echo "⚠️ 警告: 找不到 ./gphotos-config/config.hjson 設定檔，跳過 Google Photos 上傳流程。"
    else
        echo "\n🚚 [延伸自動化] 正在同步設定檔並上傳至 Google Photos..."
        ABS_PATH=$(cd "$TARGET_DIR" && pwd)
        
        # 強制更新指定子目錄內設定檔的 SourceFolder
        TARGET_PATH="$ABS_PATH" perl -pi -e 's|^\s*\"?source(Folder)?\"?\s*[:=].*|      SourceFolder: "$ENV{TARGET_PATH}"|i' ./gphotos-config/config.hjson

        # 判斷相簿決策標籤
        if [[ "$ALBUM_INPUT" == "auto" ]]; then
            echo "   -> 相簿設定：子資料夾動態範本 (template:%_directory%)"
            ALBUM_VAL="template:%_directory%" perl -pi -e 's|^\s*\"?album\"?\s*[:=].*|      Album: "$ENV{ALBUM_VAL}"|i' ./gphotos-config/config.hjson
        else
            echo "   -> 相簿設定：強制指定為 name:$ALBUM_INPUT"
            ALBUM_VAL="name:$ALBUM_INPUT" perl -pi -e 's|^\s*\"?album\"?\s*[:=].*|      Album: "$ENV{ALBUM_VAL}"|i' ./gphotos-config/config.hjson
        fi
        
        # 指向正確的組態目錄執行上傳
        gphotos-uploader-cli push --config ./gphotos-config
        echo "🎉 Sony 相片處理暨雲端上傳流程全面完成！"
    fi
else
    echo "ℹ️ 未偵測到相簿參數，僅完成本地端方向修正。"
fi