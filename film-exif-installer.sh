#!/bin/zsh

# 預設處理目前執行指令的資料夾
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "錯誤: 目錄 $TARGET_DIR 不存在。"
    exit 1
fi

# 1. 要求輸入 ISO
echo -n "👉 請輸入 ISO 數值 [預設: 400]: "
read USER_ISO
USER_ISO=${USER_ISO:-400}

# 驗證 ISO 是否為純數字
if [[ ! "$USER_ISO" =~ ^[0-9]+$ ]]; then
    echo "❌ 錯誤: ISO 必須為純數字。"
    exit 1
fi

# 2. 要求選擇作者 (Author)
echo "\n✍️ 請選擇作者 (Author):"
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

# 3. 要求選擇鏡頭
echo "\n📂 請選擇使用的鏡頭:"
echo "1) Leica Summarit-M 35mm F/2.5 [預設]"
echo "2) Leica Elmarit-M 28mm F/2.8"
echo -n "請輸入選項數字 (1 或 2，直接 Enter 則為 1): "
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
    *) echo "❌ 錯誤: 無效的鏡頭選項。"; exit 1 ;;
esac

# 4. 要求選擇菲林型號 (Film Stock)
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
    1) USER_FILM="Kodak Ultramax 400" ;;
    2) USER_FILM="Kodak Gold 200" ;;
    3) USER_FILM="Kodak Portra 400" ;;
    4) USER_FILM="Kodak Portra 800" ;;
    5) USER_FILM="Crystal 250D AHU - 5207" ;;
    6) USER_FILM="Crystal 250D AHU - 5219" ;;
    7) USER_FILM="Cinestill 800T" ;;
    8) USER_FILM="Cinestill 400D" ;;
    9) USER_FILM="Ilford Pan 100" ;;
    10) USER_FILM="Ilford Pan 400" ;;
    11)
        echo -n "✍️ 請輸入自訂菲林型號: "
        read CUSTOM_FILM
        USER_FILM=$CUSTOM_FILM
        ;;
    *) echo "❌ 錯誤: 無效的菲林選項。"; exit 1 ;;
esac

if [ -z "$USER_FILM" ]; then
    echo "❌ 錯誤: 菲林型號不能為空。"; exit 1
fi

# 5. 要求選擇或輸入沖掃公司名稱
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

echo "\n----------------------------------------"
echo "正在準備寫入以下中繼資料："
echo "相機型號: Leica MP"
echo "作者名稱: $AUTHOR_NAME"
echo "ISO 設定: $USER_ISO"
echo "鏡頭型號: $LENS_NAME"
echo "菲林型號: $USER_FILM"
echo "沖掃公司: $USER_LAB"
echo "Credit 欄位: Processed & Scanned by $USER_LAB"
echo "目標資料夾: $TARGET_DIR"
echo "----------------------------------------\n"

# 6. 呼叫 ExifTool 執行批次寫入
/opt/homebrew/bin/exiftool -overwrite_original \
    -Make="Leica Camera AG" \
    -Model="Leica MP" \
    -Artist="$AUTHOR_NAME" \
    -Creator="$AUTHOR_NAME" \
    -ISO="$USER_ISO" \
    -LensModel="$LENS_NAME" \
    -Lens="$LENS_NAME" \
    -FocalLength="$FOCAL_LENGTH" \
    -MaxApertureValue="$MAX_APERTURE" \
    -UserComment="Film Stock: $USER_FILM" \
    -XMP:Label="$USER_FILM" \
    -Credit="Processed & Scanned by $USER_LAB" \
    -Source="$USER_LAB" \
    -ext jpg -ext jpeg -ext png -ext tiff -ext dng "$TARGET_DIR"

echo "\n✨ EXIF 與菲林數據已成功批次寫入完成。"