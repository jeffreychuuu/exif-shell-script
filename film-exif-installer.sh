#!/bin/zsh

# 1. 接收命令列參數 ($1: 目錄路徑, $2: 選填相簿名稱/auto)
TARGET_DIR="${1:-.}"
ALBUM_INPUT="$2"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 錯誤: 目錄 $TARGET_DIR 不存在。"
    exit 1
fi

# ==========================================
# ─── 資料參數定義區 ───
# ==========================================
AUTHORS=("Jeffrey Chu" "Roger Chan" "Tracy Tong")
CAMERAS=("Leica Camera AG|Leica MP" "Olympus|Olympus OM-2Sp")
LEICA_LENSES=("Leica Summarit-M 35mm F/2.5|35|2.5" "Leica Elmarit-M 28mm F/2.8|28|2.8")
OLYMPUS_LENSES=("OM-System Zuiko 50mm F/1.4|50|1.4")
FILMS=(
    "Kodak Ultramax 400|400" "Kodak Gold 200|200" "Kodak ColorPlus 200|200" "Kodak Ektar 100|100"
    "Kodak Portra 160|160" "Kodak Portra 400|400" "Kodak Portra 800|800" "Fujicolor C200|200"
    "Fujicolor Superia Premium 400|400" "Lucky C200|200" "CineStill 50D|50" "CineStill 400D|400" "CineStill 800T|800"
)
LABS=("DOT-WELL Photo Workshop" "Megatoni Production" "TrueFace Pro Lab 金鈿(真面目)" "Photo Garden 金藝" "Showa")
PROCESSES=("C-41" "ECN-2" "E-6" "B&W")
PUSHPULLS=("Normal" "Push +1" "Push +2" "Pull -1")
SCANNERS=("Noritsu HS-1800" "Noritsu LS-600" "Fuji Frontier SP3000")

# ==========================================
# ─── 互動式選單邏輯區 ───
# ==========================================

# 1. 選擇 攝影師
echo "👤 請選擇攝影師 (Author):"
select AUTHOR in $AUTHORS; do
    if [ -n "$AUTHOR" ]; then break; fi
done

# 2. 選擇 相機與鏡頭
echo "\n📷 請選擇相機 (Camera):"
select CAM_OPTION in $CAMERAS; do
    if [ -n "$CAM_OPTION" ]; then
        IFS='|' read -r MAKE MODEL <<< "$CAM_OPTION"
        break
    fi
done

echo "\n🔍 請選擇鏡頭 (Lens):"
if [[ "$MODEL" == "Leica MP" ]]; then
    select LENS_OPTION in $LEICA_LENSES; do
        if [ -n "$LENS_OPTION" ]; then
            IFS='|' read -r LENS FOCAL_LENGTH MAX_APERTURE <<< "$LENS_OPTION"
            break
        fi
    done
else
    select LENS_OPTION in $OLYMPUS_LENSES; do
        if [ -n "$LENS_OPTION" ]; then
            IFS='|' read -r LENS FOCAL_LENGTH MAX_APERTURE <<< "$LENS_OPTION"
            break
        fi
    done
fi

# 3. 選擇 底片
echo "\n🎞️ 請選擇底片 (Film):"
select FILM_OPTION in $FILMS; do
    if [ -n "$FILM_OPTION" ]; then
        IFS='|' read -r FILM_NAME FILM_ISO <<< "$FILM_OPTION"
        break
    fi
done

# 4. 選擇 沖印店、工藝、增減感、掃描器
echo "\n🏪 請選擇沖印店 (Lab):"
select LAB in $LABS; do if [ -n "$LAB" ]; then break; fi; done

echo "\n🧪 請選擇沖印工藝 (Process):"
select PROCESS in $PROCESSES; do if [ -n "$PROCESS" ]; then break; fi; done

echo "\n📈 請選擇增減感 (Push/Pull):"
select PUSHPULL in $PUSHPULLS; do if [ -n "$PUSHPULL" ]; then break; fi; done

echo "\n🖨️ 請選擇掃描器 (Scanner):"
select SCANNER in $SCANNERS; do if [ -n "$SCANNER" ]; then break; fi; done

# 5. 輸入 卷號與日期
echo "\n🔢 請輸入底片卷號 (例如: 01, 12):"
read -r ROLL_NUM
printf -v ROLL_STR "%02d" "$((10#$ROLL_NUM))"

echo "\n📅 請輸入拍攝日期 (YYYYMMDD, 預設為今天):"
read -r INPUT_DATE
if [ -z "$INPUT_DATE" ]; then
    DATE_STR=$(date +"%Y%m%d")
else
    DATE_STR="$INPUT_DATE"
fi
FORMATTED_DATE="${DATE_STR:0:4}:${DATE_STR:4:2}:${DATE_STR:5:2}"

# 6. 計算時間偏移 (每卷小時自動推移)
BASE_HOUR=12
START_HOUR=$(( BASE_HOUR + 10#$ROLL_STR - 1 ))
START_MIN=00

# 將底片名稱轉換為駝峰命名法用於檔名
FILM_CAMEL=$(echo "$FILM_NAME" | awk '{for(i=1;i<=NF;i++) printf "%s", toupper(substr($i,1,1)) substr($i,2)}')

# ==========================================
# ─── ExifTool 寫入與批次命名區 ───
# ==========================================
echo "\n🚀 正在本地端批次寫入 EXIF 並重新命名檔案..."

COUNT=1
# 遍歷目標目錄下的相片（排除作業系統暫存檔）
for file in "$TARGET_DIR"/*.(jpg|JPG|jpeg|JPEG|tiff|TIFF); do
    [ -e "$file" ] || continue
    [[ "${file:t}" =~ '^\._' ]] && continue

    # 計算每張照片遞增 1 分鐘的時間戳記
    CURRENT_MIN=$(( START_MIN + COUNT - 1 ))
    HOURS_TO_ADD=$(( CURRENT_MIN / 60 ))
    FINAL_HOUR=$(( START_HOUR + HOURS_TO_ADD ))
    FINAL_MIN=$(( CURRENT_MIN % 60 ))
    
    printf -v TIME_STR "%02d:%02d:00" "$FINAL_HOUR" "$FINAL_MIN"
    DATETIME_ORIGINAL="$FORMATTED_DATE $TIME_STR"

    # 組合新檔名結構
    printf -v INDEX_STR "%02d" "$COUNT"
    EXT="${file:e}"
    NEW_NAME="${FILM_CAMEL}_Roll${ROLL_STR}_${DATE_STR}_${INDEX_STR}.${EXT}"
    DIR_NAME="${file:h}"

    # 構建軟體/備註欄位資訊
    SOFTWARE_INFO="$LAB | $PROCESS | $PUSHPULL"
    USER_COMMENT="Scanner: $SCANNER"

    # 執行 ExifTool 寫入
    /opt/homebrew/bin/exiftool -overwrite_original -q \
        -Artist="$AUTHOR" \
        -Make="$MAKE" \
        -Model="$MODEL" \
        -LensModel="$LENS" \
        -FocalLength="$FOCAL_LENGTH" \
        -MaxApertureValue="$MAX_APERTURE" \
        -ISO="$FILM_ISO" \
        -DateTimeOriginal="$DATETIME_ORIGINAL" \
        -CreateDate="$DATETIME_ORIGINAL" \
        -Software="$SOFTWARE_INFO" \
        -UserComment="$USER_COMMENT" \
        "$file"

    # 重新命名檔案
    mv "$file" "$DIR_NAME/$NEW_NAME"
    ((COUNT++))
done

echo "🎉 本地端全卷 EXIF 寫入暨重新命名完畢！"

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
        echo "🎉 菲林處理暨雲端上傳流程全面完成！"
    fi
else
    echo "ℹ️ 未偵測到相簿參數，僅完成本地端 EXIF 歸檔流程。"
fi