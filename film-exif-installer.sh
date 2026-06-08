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
echo "4) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-4，直接 Enter 則為 1): "
read AUTHOR_CHOICE

AUTHOR_CHOICE=${AUTHOR_CHOICE:-1}
case $AUTHOR_CHOICE in
    1) AUTHOR_NAME="Jeffrey Chu" ;;
    2) AUTHOR_NAME="Roger Chan" ;;
    3) AUTHOR_NAME="Tracy Tong" ;;
    4)
        echo -n "✍️ 請輸入自訂作者名稱: "
        read CUSTOM_ARTIST
        AUTHOR_NAME=$CUSTOM_ARTIST
        ;;
    *) echo "❌ 錯誤: 無效的作者選項。"; exit 1 ;;
esac

if [ -z "$AUTHOR_NAME" ]; then
    echo "❌ 錯誤: 作者名稱不能為空。"; exit 1
fi

# 2. 要求選擇相機 (Camera) 與 3. 連動鏡頭選擇 (Lens)
echo "\n📷 請選擇相機 (Camera):"
echo "1) Leica MP [預設]"
echo "2) Olympus OM-2Sp"
echo "3) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-3，直接 Enter 則為 1): "
read CAMERA_CHOICE
CAMERA_CHOICE=${CAMERA_CHOICE:-1}

NEED_CUSTOM_LENS=0

case $CAMERA_CHOICE in
    1)
        USER_MAKE="Leica Camera AG"
        USER_MODEL="Leica MP"
        
        # Leica 鏡頭專屬選單
        echo "\n📂 請選擇使用的 Leica 鏡頭:"
        echo "1) Leica Summarit-M 35mm F/2.5 [預設]"
        echo "2) Leica Elmarit-M 28mm F/2.8"
        echo "3) 其他 (自行輸入 Free text)"
        echo -n "請輸入選項數字 (1-3，直接 Enter 則為 1): "
        read LENS_CHOICE
        LENS_CHOICE=${LENS_CHOICE:-1}
        
        case $LENS_CHOICE in
            1) LENS_NAME="Leica Summarit-M 35mm F/2.5"; FOCAL_LENGTH="35"; MAX_APERTURE="2.5" ;;
            2) LENS_NAME="Leica Elmarit-M 28mm F/2.8"; FOCAL_LENGTH="28"; MAX_APERTURE="2.8" ;;
            3) NEED_CUSTOM_LENS=1 ;;
            *) echo "❌ 錯誤: 無效的鏡頭選項。"; exit 1 ;;
        esac
        ;;
    2)
        USER_MAKE="Olympus"
        USER_MODEL="Olympus OM-2Sp"
        
        # Olympus 鏡頭專屬選單
        echo "\n📂 請選擇使用的 Olympus 鏡頭:"
        echo "1) OM-System Zuiko 50mm F/1.4 [預設]"
        echo "2) 其他 (自行輸入 Free text)"
        echo -n "請輸入選項數字 (1-2，直接 Enter 則為 1): "
        read LENS_CHOICE
        LENS_CHOICE=${LENS_CHOICE:-1}
        
        case $LENS_CHOICE in
            1) LENS_NAME="OM-System Zuiko 50mm F/1.4"; FOCAL_LENGTH="50"; MAX_APERTURE="1.4" ;;
            2) NEED_CUSTOM_LENS=1 ;;
            *) echo "❌ 錯誤: 無效的鏡頭選項。"; exit 1 ;;
        esac
        ;;
    3)
        echo -n "📷 請輸入自訂相機製造商 [ Make，例如 Fujifilm ]: "
        read USER_MAKE
        USER_MAKE=${USER_MAKE:-"Unknown Make"}
        
        echo -n "📷 請輸入相機型號 [ Model，例如 GA645 ]: "
        read USER_MODEL
        USER_MODEL=${USER_MODEL:-"Unknown Model"}
        
        # 自訂相機不進行 Checking，直接開啟 Free text 鏡頭輸入
        NEED_CUSTOM_LENS=1
        ;;
    *)
        echo "❌ 錯誤: 無效的相機選項。"; exit 1
        ;;
esac

# 處理鏡頭的 Free text 輸入
if [ "$NEED_CUSTOM_LENS" -eq 1 ]; then
    echo -n "✍️ 請輸入自訂鏡頭型號 (例如 Leica Summicron-M 50mm f/2): "
    read CUSTOM_LENS
    LENS_NAME=$CUSTOM_LENS
    
    echo -n "📏 請輸入焦距數值 (純數字，例如 50，可直接 Enter 跳過): "
    read FOCAL_LENGTH
    
    echo -n "🎚️ 請輸入最大光圈值 (數字/小數，例如 2.0，可直接 Enter 跳過): "
    read MAX_APERTURE
fi

if [ -z "$LENS_NAME" ]; then
    echo "❌ 錯誤: 鏡頭型號不能為空。" ; exit 1
fi

# 4. 要求選擇菲林型號並自動判定 ISO
echo "\n🎞️ 請選擇使用的菲林型號 (Film Stock):"
echo "1) Kodak Ultramax 400 [預設]"
echo "2) Kodak Gold 200"
echo "3) Kodak ColorPlus 200"
echo "4) Kodak Ektar 100"
echo "5) Kodak Portra 160"
echo "6) Kodak Portra 400"
echo "7) Kodak Portra 800"
echo "8) Kodak Ektacolor Pro 160"
echo "9) Kodak Ektacolor Pro 400"
echo "10) Kodak Ektacolor Pro 800"
echo "11) Fujicolor C200"
echo "12) Fujicolor Superia Premium 400"
echo "13) Lucky C200"
echo "14) Crystal 250D AHU - 5207"
echo "15) Crystal 250D AHU - 5219"
echo "16) CineStill 50D"
echo "17) CineStill 400D"
echo "18) CineStill 800T"
echo "19) Ilford Pan 100"
echo "20) Ilford Pan 400"
echo "21) FilmNeverDie IRO 400"
echo "22) Retocolor Maple 100"
echo "23) CAMDI Lost in Tokyo 500"
echo "24) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-24，直接 Enter 則為 1): "
read FILM_CHOICE

FILM_CHOICE=${FILM_CHOICE:-1}
case $FILM_CHOICE in
    1)  USER_FILM="Kodak Ultramax 400";       USER_ISO=400 ;;
    2)  USER_FILM="Kodak Gold 200";           USER_ISO=200 ;;
    3)  USER_FILM="Kodak ColorPlus 200";      USER_ISO=200 ;;
    4)  USER_FILM="Kodak Ektar 100";          USER_ISO=100 ;;
    5)  USER_FILM="Kodak Portra 160";         USER_ISO=160 ;;
    6)  USER_FILM="Kodak Portra 400";         USER_ISO=400 ;;
    7)  USER_FILM="Kodak Portra 800";         USER_ISO=800 ;;
    8)  USER_FILM="Kodak Ektacolor Pro 160";  USER_ISO=160 ;;
    9)  USER_FILM="Kodak Ektacolor Pro 400";  USER_ISO=400 ;;
    10) USER_FILM="Kodak Ektacolor Pro 800";  USER_ISO=800 ;;
    11) USER_FILM="Fujicolor C200";           USER_ISO=200 ;;
    12) USER_FILM="Fujicolor Superia Premium 400"; USER_ISO=400 ;;
    13) USER_FILM="Lucky C200";               USER_ISO=200 ;;
    14) USER_FILM="Crystal 250D AHU - 5207";  USER_ISO=250 ;;
    15) USER_FILM="Crystal 250D AHU - 5219";  USER_ISO=500 ;; 
    16) USER_FILM="CineStill 50D";            USER_ISO=50  ;;
    17) USER_FILM="CineStill 400D";           USER_ISO=400 ;;
    18) USER_FILM="CineStill 800T";           USER_ISO=800 ;;
    19) USER_FILM="Ilford Pan 100";           USER_ISO=100 ;;
    20) USER_FILM="Ilford Pan 400";           USER_ISO=400 ;;
    21) USER_FILM="FilmNeverDie IRO 400";     USER_ISO=400 ;;
    22) USER_FILM="Retocolor Maple 100";      USER_ISO=100 ;;
    23) USER_FILM="CAMDI Lost in Tokyo 500";  USER_ISO=500 ;;
    24)
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

# 5. 要求選擇或輸入沖掃公司名稱
echo "\n🏢 請選擇沖掃公司:"
echo "1) DOT-WELL Photo Workshop [預設]"
echo "2) Megatoni Production"
echo "3) TrueFace Pro Lab 金鈿(真面目)"
echo "4) Photo Garden 金藝"
echo "5) HK Camera"
echo "6) Showa"
echo "7) Colorluxe Express 彩圖麗"
echo "8) Lucky 樂凱"
echo "9) Fiona"
echo "10) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-10，直接 Enter 則為 1): "
read LAB_CHOICE

LAB_CHOICE=${LAB_CHOICE:-1}
case $LAB_CHOICE in
    1) USER_LAB="DOT-WELL Photo Workshop" ;;
    2) USER_LAB="Megatoni Production" ;;
    3) USER_LAB="TrueFace Pro Lab 金鈿(真面目)" ;;
    4) USER_LAB="Photo Garden 金藝" ;;
    5) USER_LAB="HK Camera" ;;
    6) USER_LAB="Showa" ;;
    7) USER_LAB="Colorluxe Express 彩圖麗" ;;
    8) USER_LAB="Lucky 樂凱" ;;
    9) USER_LAB="Fiona" ;;
    10)
        echo -n "✍️ 請輸入自訂沖掃公司名稱: "
        read CUSTOM_LAB
        USER_LAB=$CUSTOM_LAB
        ;;
    *) echo "❌ 錯誤: 無效的沖掃公司選項。"; exit 1 ;;
esac

if [ -z "$USER_LAB" ]; then
    echo "❌ 錯誤: 沖掃公司名稱不能為空。"; exit 1
fi

# 5.1 要求選擇沖洗技術 (Developing Process)
echo "\n🧪 請選擇沖洗技術 (Developing Process):"
echo "1) C-41 [預設]"
echo "2) ECN-2"
echo "3) E-6"
echo "4) B&W"
echo "5) B&W Reversal"
echo -n "請輸入選項數字 (1-5，直接 Enter 則為 1): "
read PROCESS_CHOICE

PROCESS_CHOICE=${PROCESS_CHOICE:-1}
case $PROCESS_CHOICE in
    1) USER_PROCESS="C-41" ;;
    2) USER_PROCESS="ECN-2" ;;
    3) USER_PROCESS="E-6" ;;
    4) USER_PROCESS="B&W" ;;
    5) USER_PROCESS="B&W Reversal" ;;
    *) echo "❌ 錯誤: 無效的沖洗技術選項。"; exit 1 ;;
esac

# 5.2 要求選擇曝光處理 (Push/Pull)
echo "\n🎛️ 請選擇曝光處理 (Push/Pull):"
echo "1) Normal [預設]"
echo "2) Push +1"
echo "3) Push +2"
echo "4) Push +3"
echo "5) Pull -1"
echo "6) Pull -2"
echo "7) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-7，直接 Enter 則為 1): "
read PUSHPULL_CHOICE

PUSHPULL_CHOICE=${PUSHPULL_CHOICE:-1}
case $PUSHPULL_CHOICE in
    1) USER_PUSHPULL="Normal" ;;
    2) USER_PUSHPULL="Push +1" ;;
    3) USER_PUSHPULL="Push +2" ;;
    4) USER_PUSHPULL="Push +3" ;;
    5) USER_PUSHPULL="Pull -1" ;;
    6) USER_PUSHPULL="Pull -2" ;;
    7)
        echo -n "✍️ 請輸入自訂曝光處理 (例如 Push +1.5): "
        read CUSTOM_PUSHPULL
        USER_PUSHPULL=$CUSTOM_PUSHPULL
        ;;
    *) echo "❌ 錯誤: 無效的曝光處理選項。"; exit 1 ;;
esac

# 5.3 要求選擇掃描器 (Scanner)
echo "\n🖨 請選擇掃描器 (Scanner):"
echo "1) Noritsu HS-1800 [預設]"
echo "2) Noritsu LS-600"
echo "3) Fuji Frontier SP3000"
echo "4) Hasselblad Flextight X1"
echo "5) Hasselblad Flextight X5"
echo "6) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-6，直接 Enter 則為 1): "
read SCANNER_CHOICE

SCANNER_CHOICE=${SCANNER_CHOICE:-1}
case $SCANNER_CHOICE in
    1) USER_SCANNER="Noritsu HS-1800" ;;
    2) USER_SCANNER="Noritsu LS-600" ;;
    3) USER_SCANNER="Fuji Frontier SP3000" ;;
    4) USER_SCANNER="Hasselblad Flextight X1" ;;
    5) USER_SCANNER="Hasselblad Flextight X5" ;;
    6)
        echo -n "✍️ 請輸入自訂掃描器名稱: "
        read CUSTOM_SCANNER
        USER_SCANNER=$CUSTOM_SCANNER
        ;;
    *) echo "❌ 錯誤: 無效的掃描器選項。"; exit 1 ;;
esac

if [ -z "$USER_SCANNER" ]; then
    echo "❌ 錯誤: 掃描器名稱不能為空。"; exit 1
fi

# 6. 拍攝日期輸入
echo -n "\n📅 請輸入拍攝日期 [格式 YYYY:MM:DD，如 2026:05:20，直接 Enter 則預設為今日]: "
read USER_DATE

# 若直接按 Enter 留空，自動將變數填入今日日期
USER_DATE=${USER_DATE:-$(date +%Y:%m:%d)}

# 處理用於檔名的日期格式（抽走冒號）
FILE_DATE="${USER_DATE//:/}"


echo "\n----------------------------------------"
echo "正在準備寫入以下中繼資料與重新命名："
echo "相機製造商: $USER_MAKE"
echo "相機型號: $USER_MODEL"
echo "作者名稱: $AUTHOR_NAME"
echo "菲林型號: $USER_FILM"
echo "ISO 設定: $USER_ISO"
echo "鏡頭型號: $LENS_NAME"
echo "鏡頭焦距: ${FOCAL_LENGTH:-未指定} mm"
echo "最大光圈: F/${MAX_APERTURE:-未指定}"
echo "沖掃公司: $USER_LAB"
echo "沖洗技術: $USER_PROCESS"
echo "曝光處理: $USER_PUSHPULL"
echo "掃描儀器: $USER_SCANNER"
echo "EXIF 日期: $USER_DATE (每張相片拍攝時間遞增 1 分鐘)"
echo "檔名日期: $FILE_DATE"
echo "目標資料夾: $TARGET_DIR"
echo "----------------------------------------\n"

# ==========================================
# ─── 7. 核心處理迴圈 (排序 -> 寫入 EXIF -> 重新命名) ───
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
    [ -f "$file" ] || continue
    ext="${file:e:l}"
    
    if [[ "$ext" == "jpg" || "$ext" == "jpeg" || "$ext" == "png" || "$ext" == "tiff" || "$ext" == "dng" ]]; then
        base_name="${file:t}"
        dir_name="${file:h}"
        
        # 1. 計算「每張加 1 分鐘」的精準進位時間
        SEC=$BASE_SEC
        MIN=$(( BASE_MIN + PROCESSED_COUNT ))  
        HR=$(( BASE_HOUR + MIN / 60 ))        
        MIN=$(( MIN % 60 ))
        
        CURRENT_TIME=$(printf "%02d:%02d:%02d" $HR $MIN $SEC)
        
        # 2. 建立該檔案的 ExifTool 參數陣列（強制寫入時區 +08:00）
        # 使用 ExifTool 的雙重賦值法：先設預設為 Scanner 名稱，如果原本有 Software 欄位，則覆蓋為「原值 (Scanner)」
        exif_args=(
            -overwrite_original
            -Make="$USER_MAKE"
            -Model="$USER_MODEL"
            -Artist="$AUTHOR_NAME"
            -Creator="$AUTHOR_NAME"
            -ISO="$USER_ISO"
            -LensModel="$LENS_NAME"
            -Lens="$LENS_NAME"
            -Software="$USER_SCANNER"
            "-Software<\${Software} ($USER_SCANNER)"
            -Instructions="$USER_PROCESS ($USER_PUSHPULL)"
            -AllDates="$USER_DATE $CURRENT_TIME+08:00"
            -XMP:DateCreated="$USER_DATE $CURRENT_TIME+08:00"
            -UserComment="Film Stock: $USER_FILM | Process: $USER_PROCESS | Exposure: $USER_PUSHPULL | Scanner: $USER_SCANNER"
            -XMP:Label="$USER_FILM ($USER_PUSHPULL)"
            -Credit="Processed by $USER_LAB ($USER_PROCESS) | Scanned via $USER_SCANNER"
        )
        
        # 選擇性加入焦距
        [[ -n "$FOCAL_LENGTH" ]] && exif_args+=(-FocalLength="$FOCAL_LENGTH")
        
        # 加入光圈相關欄位（覆寫 FNumber 與 ApertureValue 確保 Google Photos 成功顯示）
        if [[ -n "$MAX_APERTURE" ]]; then
            exif_args+=(
                -MaxApertureValue="$MAX_APERTURE"
                -FNumber="$MAX_APERTURE"
                -ApertureValue="$MAX_APERTURE"
            )
        fi
        
        # 3. 呼叫 ExifTool 寫入中繼資料
        /opt/homebrew/bin/exiftool "${exif_args[@]}" "$file" > /dev/null
        
        # 4. 生成雙位數流水號 (01, 02, 03...)
        SERIAL_NUM=$(printf "%02d" $((PROCESSED_COUNT + 1)))
        
        # 5. 組合最終新檔名 (維持原有機制僅由 Film, Date 與 流水號 組成)
        new_name="${CAMEL_FILM}_${FILE_DATE}_${SERIAL_NUM}.${ext}"
        
        # 6. 執行更名
        mv "$file" "$dir_name/$new_name"
        
        ((PROCESSED_COUNT++))
        
        echo "✅ [$SERIAL_NUM] 已處理: $base_name -> $new_name (拍攝時間: $CURRENT_TIME)"
    fi
done

echo "\n🎉 全卷處理完畢！共成功同步 EXIF 並生成標準化檔名共 $PROCESSED_COUNT 張相片。"