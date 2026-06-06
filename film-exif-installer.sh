#!/bin/zsh

# 預設處理目前執行指令的資料夾
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "錯誤: 目錄 $TARGET_DIR 不存在。"
    exit 1
fi

# 1. 要求選擇作者 (Author)
echo "✍️ 請選擇作者 (Author):"
echo "1) Jeffrey Chu [預設]"
echo "2) Roger Chan"
echo "3) Tracy Tong"
echo -n "請輸入選項數字 (1, 2 或 3，直接 Enter 則為 1): "
read AUTHOR_CHOICE

AUTHOR_CHOICE=${AUTHOR_CHOICE:-1}
case $AUTHOR_CHOICE in
    1) AUTHOR_NAME="Jeffrey Chu" ;;
    2) AUTHOR_NAME="Roger Chan" ;;
    3) AUTHOR_NAME="Tracy Tong" ;;
    *) echo "❌ 錯誤: 無效的作者選項。"; exit 1 ;;
esac

# 2. 要求選擇鏡頭 (Lens)
echo "\n📂 請選擇使用的鏡頭:"
echo "1) Leica Summarit-M 35mm F/2.5 [預設]"
echo "2) Leica Elmarit-M 28mm F/2.8"
echo "3) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-3，直接 Enter 則為 1): "
read LENS_CHOICE

LENS_CHOICE=${LENS_CHOICE:-1}
case $LENS_CHOICE in
    1)
        LENS_NAME="Leica Summarit-M 35mm F/2.5"
        FOCAL_LENGTH="35"
        MAX_APERTURE="2.5"
        ;;
    2)
        LENS_NAME="Leica Elmarit-M 28mm F/2.8"
        FOCAL_LENGTH="28"
        MAX_APERTURE="2.8"
        ;;
    3)
        echo -n "✍️ 請輸入自訂鏡頭型號 (例如 Leica Summicron-M 50mm f/2): "
        read CUSTOM_LENS
        LENS_NAME=$CUSTOM_LENS
        
        echo -n "📏 請輸入焦距數值 (純數字，例如 50，可直接 Enter 跳過): "
        read FOCAL_LENGTH
        
        echo -n "🎚️ 請輸入最大光圈值 (數字/小數，例如 2.0，可直接 Enter 跳過): "
        read MAX_APERTURE
        ;;
    *) echo "❌ 錯誤: 無效的鏡頭選項。"; exit 1 ;;
esac

if [ -z "$LENS_NAME" ]; then
    echo "❌ 錯誤: 鏡頭型號不能為空。"; exit 1
fi

# 3. 要求選擇菲林型號並自動判定 ISO
echo "\n🎞️ 請選擇使用的菲林型號 (Film Stock):"
echo "1) Kodak Ultramax 400 [預設]"
echo "2) Kodak Gold 200"
echo "3) Kodak Portra 400"
echo "4) Kodak Portra 800"
echo "5) Crystal 250D AHU - 5207"
echo "6) Crystal 250D AHU - 5219"
echo "7) Cinestill 800T"
echo "8) Cinestill 400D"
echo "9) Ilford Pan 100"
echo "10) Ilford Pan 400"
echo "11) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-11，直接 Enter 則為 1): "
read FILM_CHOICE

FILM_CHOICE=${FILM_CHOICE:-1}
case $FILM_CHOICE in
    1)  USER_FILM="Kodak Ultramax 400";       USER_ISO=400 ;;
    2)  USER_FILM="Kodak Gold 200";           USER_ISO=200 ;;
    3)  USER_FILM="Kodak Portra 400";         USER_ISO=400 ;;
    4)  USER_FILM="Kodak Portra 800";         USER_ISO=800 ;;
    5)  USER_FILM="Crystal 250D AHU - 5207";  USER_ISO=250 ;;
    6)  USER_FILM="Crystal 250D AHU - 5219";  USER_ISO=500 ;; 
    7)  USER_FILM="Cinestill 800T";           USER_ISO=800 ;;
    8)  USER_FILM="Cinestill 400D";           USER_ISO=400 ;;
    9)  USER_FILM="Ilford Pan 100";           USER_ISO=100 ;;
    10) USER_FILM="Ilford Pan 400";           USER_ISO=400 ;;
    11)
        echo -n "✍️ 請輸入自訂菲林型號: "
        read CUSTOM_FILM
        USER_FILM=$CUSTOM_FILM
        
        # 自訂菲林時觸發 ISO 手動輸入
        echo -n "👉 偵測到自訂菲林，請輸入 ISO 數值: "
        read USER_ISO
        ;;
    *) echo "❌ 錯誤: 無效的菲林選項。"; exit 1 ;;
esac

# 驗證最終取得的 ISO 是否為純數字
if [[ ! "$USER_ISO" =~ ^[0-9]+$ ]]; then
    echo "❌ 錯誤: ISO 必須為純數字（目前值: $USER_ISO）。"
    exit 1
fi

if [ -z "$USER_FILM" ]; then
    echo "❌ 錯誤: 菲林型號不能為空。"; exit 1
fi

# 4. 要求選擇或輸入沖掃公司名稱
echo "\n🏢 請選擇沖掃公司:"
echo "1) DOT-WELL Photo Workshop [預設]"
echo "2) Megatoni Production"
echo "3) TrueFace Pro Lab [金鈿(真面目)]"
echo "4) Photo Garden [金藝]"
echo "5) HK Camera"
echo "6) Showa"
echo "7) Colorluxe Express [彩圖麗]"
echo "8) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-8，直接 Enter 則為 1): "
read LAB_CHOICE

LAB_CHOICE=${LAB_CHOICE:-1}
case $LAB_CHOICE in
    1) USER_LAB="DOT-WELL Photo Workshop" ;;
    2) USER_LAB="Megatoni Production" ;;
    3) USER_LAB="TrueFace Pro Lab [金鈿(真面目)]" ;;
    4) USER_LAB="Photo Garden [金藝]" ;;
    5) USER_LAB="HK Camera" ;;
    6) USER_LAB="Showa" ;;
    7) USER_LAB="Colorluxe Express [彩圖麗]" ;;
    8)
        echo -n "✍️ 請輸入自訂沖掃公司名稱: "
        read CUSTOM_LAB
        USER_LAB=$CUSTOM_LAB
        ;;
    *) echo "❌ 錯誤: 無效的沖掃公司選項。"; exit 1 ;;
esac

if [ -z "$USER_LAB" ]; then
    echo "❌ 錯誤: 沖掃公司名稱不能為空。"; exit 1
fi

# 5. 要求輸入相機製造商與型號 (Make & Model)
echo -n "\n📷 請輸入相機製造商 [預設: Leica Camera AG]: "
read USER_MAKE
USER_MAKE=${USER_MAKE:-"Leica Camera AG"}

echo -n "📷 請輸入相機型號 [預設: Leica MP]: "
read USER_MODEL
USER_MODEL=${USER_MODEL:-"Leica MP"}

# 拍攝日期輸入
echo -n "\n📅 請輸入拍攝日期 [格式 YYYY:MM:DD，如 2026:05:20，直接 Enter 則預設為今日]: "
read USER_DATE

# 【核心修正】若直接按 Enter 留空，自動將變數填入今日日期（格式 YYYY:MM:DD）
USER_DATE=${USER_DATE:-$(date +%Y:%m:%d)}

# 處理用於檔名的日期格式（抽走冒號，例如 20260606）
FILE_DATE="${USER_DATE//:/}"


echo "\n----------------------------------------"
echo "正在準備寫入以下中繼資料與重新命名："
echo "相機製造商: $USER_MAKE"
echo "相機型號: $USER_MODEL"
echo "作者名稱: $AUTHOR_NAME"
echo "菲林型號: $USER_FILM"
echo "ISO 設定: $USER_ISO"
echo "鏡頭型號: $LENS_NAME"
echo "沖掃公司: $USER_LAB"
echo "EXIF 日期: $USER_DATE (不論自訂或今日，均會執行遞增並寫入)"
echo "檔名日期: $FILE_DATE"
echo "目標資料夾: $TARGET_DIR"
echo "----------------------------------------\n"

# ==========================================
# ─── 6. 核心處理迴圈 (排序 -> 寫入 EXIF -> 重新命名) ───
# ==========================================
echo "🚚 正在開始處理相片檔案..."

# 預先處理命名所需的 Camel Case 字串變數
CAMEL_LENS="${${(C)LENS_NAME}//[^a-zA-Z0-9]/}"
CAMEL_FILM="${${(C)USER_FILM}//[^a-zA-Z0-9]/}"
CAMEL_ARTIST="${${(C)AUTHOR_NAME}//[^a-zA-Z0-9]/}"

PROCESSED_COUNT=0

# 設定時間基準點：中午 12 點正
BASE_HOUR=12
BASE_MIN=0
BASE_SEC=0

# Zsh 預設展開就會跟返 filename 由小至大排列 (Alphabetical Ascending)
for file in "$TARGET_DIR"/*; do
    # 確保是檔案而非目錄
    [ -f "$file" ] || continue
    
    # 取得副檔名並轉為小寫
    ext="${file:e:l}"
    
    # 僅處理指定的相片格式
    if [[ "$ext" == "jpg" || "$ext" == "jpeg" || "$ext" == "png" || "$ext" == "tiff" || "$ext" == "dng" ]]; then
        base_name="${file:t}"
        dir_name="${file:h}"
        
        # 1. 計算「每張加 1 分鐘」的精準進位時間
        SEC=$BASE_SEC
        MIN=$(( BASE_MIN + PROCESSED_COUNT ))  # 每張相片直接加 1 分鐘
        HR=$(( BASE_HOUR + MIN / 60 ))        # 超過 60 分鐘自動進位到小時
        MIN=$(( MIN % 60 ))
        
        # 格式化為 HH:MM:SS (補零)
        CURRENT_TIME=$(printf "%02d:%02d:%02d" $HR $MIN $SEC)
        
        # 2. 建立該檔案的 ExifTool 參數陣列（強制寫入時區 +08:00）
        exif_args=(
            -overwrite_original
            -Make="$USER_MAKE"
            -Model="$USER_MODEL"
            -Artist="$AUTHOR_NAME"
            -Creator="$AUTHOR_NAME"
            -ISO="$USER_ISO"
            -LensModel="$LENS_NAME"
            -Lens="$LENS_NAME"
            -AllDates="$USER_DATE $CURRENT_TIME+08:00"
            -XMP:DateCreated="$USER_DATE $CURRENT_TIME+08:00"
            -UserComment="Film Stock: $USER_FILM"
            -XMP:Label="$USER_FILM"
            -Credit="Processed & Scanned by $USER_LAB"
            -Source="$USER_LAB"
        )
        
        # 選擇性加入焦距與光圈
        [[ -n "$FOCAL_LENGTH" ]] && exif_args+=(-FocalLength="$FOCAL_LENGTH")
        [[ -n "$MAX_APERTURE" ]] && exif_args+=(-MaxApertureValue="$MAX_APERTURE")
        
        # 3. 呼叫 ExifTool 寫入中繼資料
        /opt/homebrew/bin/exiftool "${exif_args[@]}" "$file" > /dev/null
        
        # 4. 生成雙位數流水號 (01, 02, 03...)
        SERIAL_NUM=$(printf "%02d" $((PROCESSED_COUNT + 1)))
        
        # 5. 組合最終新檔名
        new_name="${CAMEL_LENS}_${CAMEL_FILM}_${CAMEL_ARTIST}_${FILE_DATE}_${SERIAL_NUM}.${ext}"
        
        # 6. 執行更名
        mv "$file" "$dir_name/$new_name"
        
        ((PROCESSED_COUNT++))
        
        # 即時顯示進度提示
        echo "✅ [$SERIAL_NUM] 已處理: $base_name -> $new_name (拍攝時間: $CURRENT_TIME)"
    fi
done

echo "\n🎉 全卷處理完畢！共成功同步 EXIF 並生成標準化檔名共 $PROCESSED_COUNT 張相片。"