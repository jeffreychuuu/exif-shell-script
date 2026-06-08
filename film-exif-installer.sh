#!/bin/zsh

# 預設處理目前執行指令的資料夾
TARGET_DIR="${1:-.}"
ALBUM_INPUT="${@:2}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "錯誤: 目錄 $TARGET_DIR 不存在。"
    exit 1
fi

# ==========================================
# ─── 資料參數定義區 ───
# ==========================================
AUTHORS=("Jeffrey Chu" "Roger Chan" "Tracy Tong")

# 格式: "Make|Model"
CAMERAS=(
    "Leica Camera AG|Leica MP"
    "Olympus|Olympus OM-2Sp"
    "Lomography|Lomography Simple Use"
)

# 格式: "LensName|FocalLength|MaxAperture"
LEICA_LENSES=(
    "Leica Summarit-M 35mm F/2.5|35|2.5"
    "Leica Elmarit-M 28mm F/2.8|28|2.8"
)
OLYMPUS_LENSES=(
    "OM-System Zuiko 50mm F/1.4|50|1.4"
)
LOMOGRAPHY_SIMPLE_USE_LENSES=(
    "Plastic Lens 35mm F/9|35|9"
)

# 格式: "FilmStockName|ISO"
FILMS=(
    "Kodak Ultramax 400|400"
    "Kodak Gold 200|200"
    "Kodak ColorPlus 200|200"
    "Kodak Ektar 100|100"
    "Kodak Portra 160|160"
    "Kodak Portra 400|400"
    "Kodak Portra 800|800"
    "Kodak Ektacolor Pro 160|160"
    "Kodak Ektacolor Pro 400|400"
    "Kodak Ektacolor Pro 800|800"
    "Fujicolor C200|200"
    "Fujicolor Superia Premium 400|400"
    "Lucky C200|200"
    "Crystal 250D AHU - 5207|250"
    "Crystal 250D AHU - 5219|500"
    "CineStill 50D|50"
    "CineStill 400D|400"
    "CineStill 800T|800"
    "Ilford Pan 100|100"
    "Ilford Pan 400|400"
    "FilmNeverDie IRO 400|400"
    "Retocolor Maple 100|100"
    "CAMDI Lost in Tokyo 500|500"
)

LABS=(
    "DOT-WELL Photo Workshop"
    "Megatoni Production"
    "TrueFace Pro Lab 金鈿(真面目)"
    "Photo Garden 金藝"
    "HK Camera"
    "Showa"
    "Colorluxe Express 彩圖麗"
    "Lucky 樂凱"
    "Fiona"
)

PROCESSES=("C-41" "ECN-2" "E-6" "B&W" "B&W Reversal")
PUSHPULLS=("Normal" "Push +1" "Push +2" "Push +3" "Pull -1" "Pull -2")
SCANNERS=("Noritsu HS-1800" "Noritsu LS-600" "Fuji Frontier SP3000" "Hasselblad Flextight X1" "Hasselblad Flextight X5")

# ==========================================
# ─── 互動式選單邏輯區 ───
# ==========================================
REDO="all"
while true; do

if [[ "$REDO" == "all" || "$REDO" == "1" ]]; then
# 1. 選擇作者
echo "✍️ 請選擇作者 (Author):"
for i in {1..$#AUTHORS}; do
    [[ $i -eq 1 ]] && echo "$i) $AUTHORS[$i] [預設]" || echo "$i) $AUTHORS[$i]"
done
OTHER_AUTH=$(( $#AUTHORS + 1 ))
echo "$OTHER_AUTH) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-$OTHER_AUTH，直接 Enter 則為預設): "
read AUTHOR_CHOICE
AUTHOR_CHOICE=${AUTHOR_CHOICE:-1}

if [[ "$AUTHOR_CHOICE" -eq "$OTHER_AUTH" ]]; then
    echo -n "✍️ 請輸入自訂作者名稱: "
    read CUSTOM_ARTIST
        AUTHOR_NAME=$CUSTOM_ARTIST
elif [[ "$AUTHOR_CHOICE" -ge 1 && "$AUTHOR_CHOICE" -le "$#AUTHORS" ]]; then
    AUTHOR_NAME=$AUTHORS[$AUTHOR_CHOICE]
else
    echo "❌ 錯誤: 無效的作者選項。"; exit 1
fi

if [ -z "$AUTHOR_NAME" ]; then
    echo "❌ 錯誤: 作者名稱不能為空。"; exit 1
fi
fi  # end section 1

# 2. 選擇相機 與 3. 連動鏡頭
if [[ "$REDO" == "all" || "$REDO" == "2" ]]; then
echo "\n📷 請選擇相機 (Camera):"
for i in {1..$#CAMERAS}; do
    c_parts=(${(s:|:)CAMERAS[$i]})
    [[ $i -eq 1 ]] && echo "$i) $c_parts[2] [預設]" || echo "$i) $c_parts[2]"
done
OTHER_CAM=$(( $#CAMERAS + 1 ))
echo "$OTHER_CAM) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-$OTHER_CAM，直接 Enter 則為預設): "
read CAMERA_CHOICE
CAMERA_CHOICE=${CAMERA_CHOICE:-1}

NEED_CUSTOM_LENS=0
SHUTTER_SPEED=""

if [[ "$CAMERA_CHOICE" -ge 1 && "$CAMERA_CHOICE" -le "$#CAMERAS" ]]; then
    c_parts=(${(s:|:)CAMERAS[$CAMERA_CHOICE]})
    USER_MAKE=$c_parts[1]
    USER_MODEL=$c_parts[2]
    
    if [[ "$CAMERA_CHOICE" -eq 1 ]]; then
        TARGET_LENSES=("${LEICA_LENSES[@]}")
    elif [[ "$CAMERA_CHOICE" -eq 2 ]]; then
        TARGET_LENSES=("${OLYMPUS_LENSES[@]}")
    elif [[ "$CAMERA_CHOICE" -eq 3 ]]; then
        TARGET_LENSES=("${LOMOGRAPHY_SIMPLE_USE_LENSES[@]}")
        SHUTTER_SPEED="1/120"
    fi
    
    echo "\n📂 請選擇使用的鏡頭:"
    for i in {1..$#TARGET_LENSES}; do
        l_parts=(${(s:|:)TARGET_LENSES[$i]})
        [[ $i -eq 1 ]] && echo "$i) $l_parts[1] [預設]" || echo "$i) $l_parts[1]"
    done
    OTHER_LENS=$(( $#TARGET_LENSES + 1 ))
    echo "$OTHER_LENS) 其他 (自行輸入 Free text)"
    echo -n "請輸入選項數字 (1-$OTHER_LENS，直接 Enter 則為預設): "
    read LENS_CHOICE
        LENS_CHOICE=${LENS_CHOICE:-1}
    
    if [[ "$LENS_CHOICE" -eq "$OTHER_LENS" ]]; then
        NEED_CUSTOM_LENS=1
    elif [[ "$LENS_CHOICE" -ge 1 && "$LENS_CHOICE" -le "$#TARGET_LENSES" ]]; then
        l_parts=(${(s:|:)TARGET_LENSES[$LENS_CHOICE]})
        LENS_NAME=$l_parts[1]
        FOCAL_LENGTH=$l_parts[2]
        MAX_APERTURE=$l_parts[3]
    else
        echo "❌ 錯誤: 無效的鏡頭選項。"; exit 1
    fi
elif [[ "$CAMERA_CHOICE" -eq "$OTHER_CAM" ]]; then
    echo -n "📷 請輸入自訂相機製造商 [ Make，例如 Fujifilm ]: "
    read USER_MAKE
        USER_MAKE=${USER_MAKE:-"Unknown Make"}
    
    echo -n "📷 請輸入相機型號 [ Model，例如 GA645 ]: "
    read USER_MODEL
        USER_MODEL=${USER_MODEL:-"Unknown Model"}
    NEED_CUSTOM_LENS=1
else
    echo "❌ 錯誤: 無效的相機選項。"; exit 1
fi

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
    echo "❌ 錯誤: 鏡頭型號不能為空。"; exit 1
fi
fi  # end section 2

# 3. 選擇菲林型號與 ISO
if [[ "$REDO" == "all" || "$REDO" == "3" ]]; then
echo "\n🎞️ 請選擇使用的菲林型號 (Film Stock):"
for i in {1..$#FILMS}; do
    f_parts=(${(s:|:)FILMS[$i]})
    [[ $i -eq 1 ]] && echo "$i) $f_parts[1] [預設]" || echo "$i) $f_parts[1]"
done
OTHER_FILM=$(( $#FILMS + 1 ))
echo "$OTHER_FILM) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-$OTHER_FILM，直接 Enter 則為預設): "
read FILM_CHOICE
FILM_CHOICE=${FILM_CHOICE:-1}

if [[ "$FILM_CHOICE" -eq "$OTHER_FILM" ]]; then
    echo -n "✍️ 請輸入自訂菲林型號: "
    read CUSTOM_FILM
        USER_FILM=$CUSTOM_FILM
    echo -n "👉 偵測到自訂菲林，請輸入 ISO 數值: "
    read USER_ISO
    elif [[ "$FILM_CHOICE" -ge 1 && "$FILM_CHOICE" -le "$#FILMS" ]]; then
    f_parts=(${(s:|:)FILMS[$FILM_CHOICE]})
    USER_FILM=$f_parts[1]
    USER_ISO=$f_parts[2]
else
    echo "❌ 錯誤: 無效的菲林選項。"; exit 1
fi

if [[ ! "$USER_ISO" =~ ^[0-9]+$ ]]; then
    echo "❌ 錯誤: ISO 必須為純數字（目前值: $USER_ISO）。"
    exit 1
fi

if [ -z "$USER_FILM" ]; then
    echo "❌ 錯誤: 菲林型號不能為空。"; exit 1
fi
fi  # end section 3

# 4. 選擇沖掃公司
if [[ "$REDO" == "all" || "$REDO" == "4" ]]; then
echo "\n🏢 請選擇沖掃公司:"
for i in {1..$#LABS}; do
    [[ $i -eq 1 ]] && echo "$i) $LABS[$i] [預設]" || echo "$i) $LABS[$i]"
done
OTHER_LAB=$(( $#LABS + 1 ))
echo "$OTHER_LAB) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-$OTHER_LAB，直接 Enter 則為預設): "
read LAB_CHOICE
LAB_CHOICE=${LAB_CHOICE:-1}

if [[ "$LAB_CHOICE" -eq "$OTHER_LAB" ]]; then
    echo -n "✍️ 請輸入自訂沖掃公司名稱: "
    read CUSTOM_LAB
        USER_LAB=$CUSTOM_LAB
elif [[ "$LAB_CHOICE" -ge 1 && "$LAB_CHOICE" -le "$#LABS" ]]; then
    USER_LAB=$LABS[$LAB_CHOICE]
else
    echo "❌ 錯誤: 無效的沖掃公司選項。"; exit 1
fi

if [ -z "$USER_LAB" ]; then
    echo "❌ 錯誤: 沖掃公司名稱不能為空。"; exit 1
fi
fi  # end section 4

# 5. 選擇沖洗技術
if [[ "$REDO" == "all" || "$REDO" == "5" ]]; then
echo "\n🧪 請選擇沖洗技術 (Developing Process):"
for i in {1..$#PROCESSES}; do
    [[ $i -eq 1 ]] && echo "$i) $PROCESSES[$i] [預設]" || echo "$i) $PROCESSES[$i]"
done
echo -n "請輸入選項數字 (1-$#PROCESSES，直接 Enter 則為預設): "
read PROCESS_CHOICE
PROCESS_CHOICE=${PROCESS_CHOICE:-1}

if [[ "$PROCESS_CHOICE" -ge 1 && "$PROCESS_CHOICE" -le "$#PROCESSES" ]]; then
    USER_PROCESS=$PROCESSES[$PROCESS_CHOICE]
else
    echo "❌ 錯誤: 無效的沖洗技術選項。"; exit 1
fi
fi  # end section 5

# 6. 選擇曝光處理
if [[ "$REDO" == "all" || "$REDO" == "6" ]]; then
echo "\n🎛️ 請選擇曝光處理 (Push/Pull):"
for i in {1..$#PUSHPULLS}; do
    [[ $i -eq 1 ]] && echo "$i) $PUSHPULLS[$i] [預設]" || echo "$i) $PUSHPULLS[$i]"
done
OTHER_PP=$(( $#PUSHPULLS + 1 ))
echo "$OTHER_PP) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-$OTHER_PP，直接 Enter 則為預設): "
read PUSHPULL_CHOICE
PUSHPULL_CHOICE=${PUSHPULL_CHOICE:-1}

if [[ "$PUSHPULL_CHOICE" -eq "$OTHER_PP" ]]; then
    echo -n "✍️ 請輸入自訂曝光處理 (例如 Push +1.5): "
    read CUSTOM_PUSHPULL
        USER_PUSHPULL=$CUSTOM_PUSHPULL
elif [[ "$PUSHPULL_CHOICE" -ge 1 && "$PUSHPULL_CHOICE" -le "$#PUSHPULLS" ]]; then
    USER_PUSHPULL=$PUSHPULLS[$PUSHPULL_CHOICE]
else
    echo "❌ 錯誤: 無效的曝光處理選項。"; exit 1
fi
fi  # end section 6

# 7. 選擇掃描器
if [[ "$REDO" == "all" || "$REDO" == "7" ]]; then
echo "\n🖨 請選擇掃描器 (Scanner):"
for i in {1..$#SCANNERS}; do
    [[ $i -eq 1 ]] && echo "$i) $SCANNERS[$i] [預設]" || echo "$i) $SCANNERS[$i]"
done
OTHER_SCAN=$(( $#SCANNERS + 1 ))
echo "$OTHER_SCAN) 其他 (自行輸入 Free text)"
echo -n "請輸入選項數字 (1-$OTHER_SCAN，直接 Enter 則為預設): "
read SCANNER_CHOICE
SCANNER_CHOICE=${SCANNER_CHOICE:-1}

if [[ "$SCANNER_CHOICE" -eq "$OTHER_SCAN" ]]; then
    echo -n "✍️ 請輸入自訂掃描器名稱: "
    read CUSTOM_SCANNER
        USER_SCANNER=$CUSTOM_SCANNER
elif [[ "$SCANNER_CHOICE" -ge 1 && "$SCANNER_CHOICE" -le "$#SCANNERS" ]]; then
    USER_SCANNER=$SCANNERS[$SCANNER_CHOICE]
else
    echo "❌ 錯誤: 無效的掃描器選項。"; exit 1
fi

if [ -z "$USER_SCANNER" ]; then
    echo "❌ 錯誤: 掃描器名稱不能為空。"; exit 1
fi
fi  # end section 7

# ==========================================
# ─── 8. 日期與時間處理邏輯 ───
# ==========================================
if [[ "$REDO" == "all" || "$REDO" == "8" ]]; then
DATE_SEGMENTS=()

TOTAL_FILES=0
for f in "$TARGET_DIR"/*; do
    [ -f "$f" ] || continue
    e="${f:e:l}"
    [[ "$e" == "jpg" || "$e" == "jpeg" || "$e" == "png" || "$e" == "tiff" || "$e" == "dng" ]] && ((TOTAL_FILES++))
done

echo "\n📊 目標目錄共有 $TOTAL_FILES 個相片檔案。"

echo -n "\n📅 所有相片是否都是同一拍攝日期？(Y/n) [直接 Enter 則預設為是]: "
read SAME_DATE
SAME_DATE=${SAME_DATE:-y}
SAME_DATE=${SAME_DATE:l}

declare -a DATE_SEGMENTS
if [[ "$SAME_DATE" == "y" || "$SAME_DATE" == "yes" ]]; then
    while true; do
        echo -n "📅 請輸入拍攝日期 [格式 YYYYMMDD 或 YYYY:MM:DD，如 20260606，直接 Enter 則預設為今日]: "
        read DATE_INPUT
        if [ -z "$DATE_INPUT" ]; then
            EXIF_DATE=$(date +%Y:%m:%d)
            FILE_DATE=$(date +%Y%m%d)
            break
        fi
        if [[ "$DATE_INPUT" =~ ^[0-9]{8}$ ]]; then
            FILE_DATE=$DATE_INPUT
            EXIF_DATE="${DATE_INPUT[1,4]}:${DATE_INPUT[5,6]}:${DATE_INPUT[7,8]}"
            break
        elif [[ "$DATE_INPUT" =~ ^[0-9]{4}:[0-1][0-9]:[0-3][0-9]$ ]]; then
            EXIF_DATE=$DATE_INPUT
            FILE_DATE="${DATE_INPUT//:/}"
            break
        else
            echo "❌ 錯誤: 日期格式無效。請輸入 8 位純數字 (如 20260606) 或標準格式 (如 2026:06:06)。"
        fi
    done
        echo ""
    while true; do
        echo -n "⏰ 請輸入此段基準開始時間 (24小時制 格式 HH:MM 或 HHMM，如 12:00 或 1200，直接 Enter 則預設為 12:00): "
        read CUSTOM_TIME
        if [ -z "$CUSTOM_TIME" ]; then
            SEG_START_HOUR=12
            SEG_START_MIN=0
            break
        fi
        if [[ "$CUSTOM_TIME" =~ ^([0-1][0-9]|2[0-3]):([0-5][0-9])$ ]]; then
            SEG_START_HOUR=$(( 10#${match[1]} ))
            SEG_START_MIN=$(( 10#${match[2]} ))
            break
        elif [[ "$CUSTOM_TIME" =~ ^([0-1][0-9]|2[0-3])([0-5][0-9])$ ]]; then
            SEG_START_HOUR=$(( 10#${match[1]} ))
            SEG_START_MIN=$(( 10#${match[2]} ))
            break
        else
            echo "❌ 錯誤: 時間格式錯誤，請輸入 HH:MM 或 HHMM (例如 12:00 或 1200)。"
        fi
    done
        DATE_SEGMENTS+=("1|$TOTAL_FILES|$FILE_DATE|$EXIF_DATE|$SEG_START_HOUR|$SEG_START_MIN")
else
    remaining=$TOTAL_FILES
    start_idx=1
    while [ $remaining -gt 0 ]; do
        max_end=$(( start_idx + remaining - 1 ))
        while true; do
            echo -n "\n📅 第 $start_idx 張至第幾張是同一拍攝日期？( $start_idx 至 $max_end，直接 Enter 預設為最後一張): "
            read SEG_END
            SEG_END=${SEG_END:-$max_end}
            if [[ "$SEG_END" =~ ^[0-9]+$ ]] && [ "$SEG_END" -ge "$start_idx" ] && [ "$SEG_END" -le "$max_end" ]; then
                break
            else
                echo "❌ 錯誤: 請輸入 $start_idx 至 $max_end 之間的數字。"
            fi
        done
                while true; do
            echo -n "👉 請輸入此段拍攝日期 [格式 YYYYMMDD 或 YYYY:MM:DD]: "
            read DATE_INPUT
            if [[ "$DATE_INPUT" =~ ^[0-9]{8}$ ]]; then
                SEG_FDATE=$DATE_INPUT
                SEG_EDATE="${DATE_INPUT[1,4]}:${DATE_INPUT[5,6]}:${DATE_INPUT[7,8]}"
                break
            elif [[ "$DATE_INPUT" =~ ^[0-9]{4}:[0-1][0-9]:[0-3][0-9]$ ]]; then
                SEG_EDATE=$DATE_INPUT
                SEG_FDATE="${DATE_INPUT//:/}"
                break
            else
                echo "❌ 錯誤: 日期格式無效。請輸入 8 位純數字 (如 20260606) 或標準格式 (如 2026:06:06)。"
            fi
        done
                echo ""
        while true; do
            echo -n "⏰ 請輸入此段基準開始時間 (24小時制 格式 HH:MM 或 HHMM，如 12:00 或 1200，直接 Enter 則預設為 12:00): "
            read CUSTOM_TIME
            if [ -z "$CUSTOM_TIME" ]; then
                SEG_START_HOUR=12
                SEG_START_MIN=0
                break
            fi
            if [[ "$CUSTOM_TIME" =~ ^([0-1][0-9]|2[0-3]):([0-5][0-9])$ ]]; then
                SEG_START_HOUR=$(( 10#${match[1]} ))
                SEG_START_MIN=$(( 10#${match[2]} ))
                break
            elif [[ "$CUSTOM_TIME" =~ ^([0-1][0-9]|2[0-3])([0-5][0-9])$ ]]; then
                SEG_START_HOUR=$(( 10#${match[1]} ))
                SEG_START_MIN=$(( 10#${match[2]} ))
                break
            else
                echo "❌ 錯誤: 時間格式錯誤，請輸入 HH:MM 或 HHMM (例如 12:00 或 1200)。"
            fi
        done
                DATE_SEGMENTS+=("$start_idx|$SEG_END|$SEG_FDATE|$SEG_EDATE|$SEG_START_HOUR|$SEG_START_MIN")
        start_idx=$(( SEG_END + 1 ))
        remaining=$(( TOTAL_FILES - SEG_END ))
    done
    fi

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
[[ -n "$SHUTTER_SPEED" ]] && echo "快門速度: $SHUTTER_SPEED"
echo "沖掃公司: $USER_LAB"
echo "沖洗技術: $USER_PROCESS"
echo "曝光處理: $USER_PUSHPULL"
echo "掃描儀器: $USER_SCANNER"
echo "日期分段: ${#DATE_SEGMENTS[@]} 個區段"
for seg in "${DATE_SEGMENTS[@]}"; do
    seg_start="${seg%%|*}"
    rest="${seg#*|}"
    seg_end="${rest%%|*}"
    rest="${rest#*|}"
    seg_fdate="${rest%%|*}"
    rest="${rest#*|}"
    seg_edate="${rest%%|*}"
    rest="${rest#*|}"
    seg_shour="${rest%%|*}"
    seg_smin="${rest#*|}"
    echo "  → 第 $seg_start 至第 $seg_end 張: $seg_fdate (起始時間 $(printf "%02d:%02d" $seg_shour $seg_smin)，每張遞增 1 分鐘)"
done
echo "目標資料夾: $TARGET_DIR"
echo "----------------------------------------\n"
fi  # end section 8

echo "────────────────────────────────────────"
echo "  [1] 作者       [2] 相機+鏡頭   [3] 菲林+ISO"
echo "  [4] 沖掃公司   [5] 沖洗技術    [6] 曝光處理"
echo "  [7] 掃描器     [8] 日期與時間"
echo "────────────────────────────────────────"
echo -n "✅ 以上設定是否正確？(直接 Enter 確認 / 輸入 1-8 返回修改該區段 / q 退出): "
read CONFIRM
CONFIRM=${CONFIRM:-y}
if [[ "$CONFIRM" == "y" || "$CONFIRM" == "yes" || -z "$CONFIRM" ]]; then
    break
elif [[ "$CONFIRM" == "q" || "$CONFIRM" == "quit" ]]; then
    echo "👋 已退出"
    exit 0
elif [[ "$CONFIRM" =~ ^[1-8]$ ]]; then
    REDO="$CONFIRM"
else
    REDO="all"
fi
done

# ==========================================
# ─── 9. 相片上載 ───
# ==========================================
echo "🚚 正在開始處理相片檔案..."

CAMEL_LENS="${${(C)LENS_NAME}//[^a-zA-Z0-9]/}"
CAMEL_FILM="${${(C)USER_FILM}//[^a-zA-Z0-9]/}"
CAMEL_ARTIST="${${(C)AUTHOR_NAME}//[^a-zA-Z0-9]/}"

PROCESSED_COUNT=0

for file in "$TARGET_DIR"/*; do
    [ -f "$file" ] || continue
    ext="${file:e:l}"
    
    if [[ "$ext" == "jpg" || "$ext" == "jpeg" || "$ext" == "png" || "$ext" == "tiff" || "$ext" == "dng" ]]; then
        base_name="${file:t}"
        dir_name="${file:h}"
        
        idx=$((PROCESSED_COUNT + 1))
        FILE_DATE=""
        EXIF_DATE=""
        for seg in "${DATE_SEGMENTS[@]}"; do
            seg_start="${seg%%|*}"
            rest="${seg#*|}"
            seg_end="${rest%%|*}"
            rest="${rest#*|}"
            seg_fdate="${rest%%|*}"
            rest="${rest#*|}"
            seg_edate="${rest%%|*}"
            rest="${rest#*|}"
            seg_shour="${rest%%|*}"
            seg_smin="${rest#*|}"
            if [ "$idx" -ge "$seg_start" ] && [ "$idx" -le "$seg_end" ]; then
                FILE_DATE=$seg_fdate
                EXIF_DATE=$seg_edate
                break
            fi
        done
        
        offset=$(( idx - seg_start ))
        MIN=$(( seg_smin + offset ))
        HR=$(( seg_shour + MIN / 60 ))
        MIN=$(( MIN % 60 ))
        HR=$(( HR % 24 ))
        SEC=0
        
        CURRENT_TIME=$(printf "%02d:%02d:%02d" $HR $MIN $SEC)
        
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
            '-Software<${Software} '"($USER_SCANNER)"
            -Instructions="$USER_PROCESS ($USER_PUSHPULL)"
            -AllDates="$EXIF_DATE $CURRENT_TIME+08:00"
            -XMP:DateCreated="$EXIF_DATE $CURRENT_TIME+08:00"
            -UserComment="Film Stock: $USER_FILM | Process: $USER_PROCESS | Exposure: $USER_PUSHPULL${SHUTTER_SPEED:+ | Shutter: $SHUTTER_SPEED} | Scanner: $USER_SCANNER"
            -XMP:Label="$USER_FILM ($USER_PUSHPULL)"
            -Credit="Processed by $USER_LAB ($USER_PROCESS) | Scanned via $USER_SCANNER"
            -XMP-dc:Description="Photo by $AUTHOR_NAME | Camera: $USER_MODEL ($LENS_NAME) | Film: $USER_FILM (ISO $USER_ISO)${SHUTTER_SPEED:+ | Shutter: $SHUTTER_SPEED} | Lab: $USER_LAB | Process: $USER_PROCESS ($USER_PUSHPULL) | Scanner: $USER_SCANNER"
        )
        
        [[ -n "$FOCAL_LENGTH" ]] && exif_args+=(-FocalLength="$FOCAL_LENGTH")
        [[ -n "$SHUTTER_SPEED" ]] && exif_args+=(-ExposureTime="$SHUTTER_SPEED")
        [[ -n "$SHUTTER_SPEED" ]] && exif_args+=(-ShutterSpeedValue="$SHUTTER_SPEED")
        
        if [[ -n "$MAX_APERTURE" ]]; then
            exif_args+=(
                -MaxApertureValue="$MAX_APERTURE"
                -FNumber="$MAX_APERTURE"
                -ApertureValue="$MAX_APERTURE"
            )
        fi
        
        /opt/homebrew/bin/exiftool "${exif_args[@]}" "$file" > /dev/null
        
        SERIAL_NUM=$(printf "%02d" $idx)
        TIME_STR=$(printf "%02d%02d" $HR $MIN)
        new_name="${CAMEL_FILM}_${FILE_DATE}${TIME_STR}_${SERIAL_NUM}.${ext}"
        mv "$file" "$dir_name/$new_name"
        
        ((PROCESSED_COUNT++))
        echo "✅ [$SERIAL_NUM] 已處理: $base_name -> $new_name (拍攝時間: $CURRENT_TIME)"
    fi
done

echo "\n🎉 處理完畢！共成功同步 EXIF 並生成標準化檔名共 $PROCESSED_COUNT 張相片。"

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