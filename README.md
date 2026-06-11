# Exif Shell Script 工具集

本專案提供用於處理相片 EXIF 中繼資料、自動重新命名與雲端同步上傳的 Zsh 腳本工具。

Web 版本已獨立為 [FilmTag](https://github.com/jeffreychuuu/filmtag) → [filmtag.jeffreychuuu.com](https://filmtag.jeffreychuuu.com)

---

## 📂 專案結構與檔案總覽

```text
exif-shell-script/
├── .gitignore                  # Git 忽略設定（自動隔離私密憑證與本地快取）
├── README.md                   # 本說明文件
├── data.json                   # 📋 參數資料定義（與 FilmTag 共用）
├── film-exif-installer.sh      # 菲林中繼資料批次寫入暨命名工具
├── fix-sony-hif-orientation.sh # Sony HIF/HEIC 方向遞迴修正工具
└── gphotos-config/             # 🪺 Google Photos 同步配置專用資料夾
    ├── config.example.hjson    # 設定檔範本（可公開推至 GitHub）
    ├── config.hjson            # 實體私密設定檔（Git 自動忽略）
    ├── tokens/                 # Google OAuth 授權憑證快取（Git 自動忽略）
    ├── uploaded_files/         # 已成功上傳的檔案去重資料庫（Git 自動忽略）
    └── ongoing_uploads/        # 斷點續傳暫存快取區（Git 自動忽略）
```

## 📦 Homebrew 依賴套件

執行本專案工具前，需先透過 [Homebrew](https://brew.sh) 安裝以下兩項命令列工具。

| 套件名稱                 | 安裝指令                            | 用途說明                                                                                                                       | 官方 GitHub                                                                                     |
| :----------------------- | :---------------------------------- | :----------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------- |
| **exiftool**             | `brew install exiftool`             | Perl 語言編寫的 EXIF 中繼資料讀寫工具，用於批次寫入相機型號、鏡頭、底片 ISO、沖掃資訊等欄位至相片檔案中。                      | [exiftool/exiftool](https://github.com/exiftool/exiftool)                                       |
| **gphotos-uploader-cli** | `brew install gphotos-uploader-cli` | Go 語言編寫的 Google Photos 命令列上傳工具，用於將處理完成的相片批次同步至雲端相簿。僅在使用第二參數觸發雲端上傳時才需此依賴。 | [gphotosuploader/gphotos-uploader-cli](https://github.com/gphotosuploader/gphotos-uploader-cli) |

> 💡 首次使用前，請先確保上述兩項套件已透過 Homebrew 正確安裝，否則腳本將無法執行 EXIF 寫入或雲端同步功能。

### 📋 核心檔案功能一覽

| 腳本/檔案名稱                 | 主要用途                                              | 核心特性                                                                                                      |
| :---------------------------- | :---------------------------------------------------- | :------------------------------------------------------------------------------------------------------------ |
| `film-exif-installer.sh`      | 批次寫入菲林中繼資料與自動重新命名                    | 互動式選單、自動對應 ISO、**多日期分段+各自獨立起始時間**、**設定確認與編號返回修改機制**、選填一鍵同步上傳。 |
| `fix-sony-hif-orientation.sh` | 批次修正 Sony 相機 `.hif` / `.heic` 的檔案旋轉角度    | **全面遞迴（Recursive）**深入所有子資料夾、提取原始相機方向寫入標準 EXIF、選填一鍵同步上傳。                  |
| `gphotos-config/`             | 集中收納所有與 Google Photos 上傳相關的組態與本機暫存 | 實行「單一事實來源」架構。腳本執行時會自動動態重寫此目錄下的 `config.hjson`，無須手動介入。                   |

## 🛠️ 統一命令列參數使用指南

兩大腳本皆採用完全一致的參數設計，同時支援「相對路徑」與「絕對路徑」。透過第二參數，可動態決定是否觸發 Google Photos 自動同步。

### 📖 參數組合與雲端行為對照表

| 使用場景模式                                    | 第二參數輸入範例   | `config.hjson` 欄位動態重寫結果                                   | Google Photos 雲端相簿實際行為                                                                                                      |
| :---------------------------------------------- | :----------------- | :---------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
| **1. 純本地處理**<br>（不上傳雲端）             | _不填寫第二參數_   | _不觸發上傳流程，不改寫設定檔_                                    | 僅完成本地端相片的 EXIF 寫入、重新命名或方向修正，適合本機歸檔。                                                                    |
| **2. 動態自動分類**<br>（依來源目錄名稱建相簿） | **`auto`**         | `SourceFolder: "/.../實體路徑"`<br>`Album: "name:<來源目錄名稱>"` | 自動提取來源目錄 (SourceFolder) 的最底層資料夾名稱作為雲端相簿名稱進行上傳。                                                        |
| **3. 強制指定相簿**<br>（全數塞入特定相簿）     | **`自訂相簿名稱`** | `SourceFolder: "/.../實體路徑"`<br>`Album: "name:自訂相簿名稱"`   | 忽略任何子資料夾結構，強制將該路徑下所有相片打包上傳至雲端指定名稱的單一相簿中。<br>⚠️ 支援含空格的名稱直接輸入，無需用 `""` 包住。 |

### 💻 指令執行範例

```shell
# ----------------------------------------------------
# 範例 A：處理菲林相片
# ----------------------------------------------------
# 僅進行本地 EXIF 寫入與重新命名
film ./my_photos
# 或使用完整腳本路徑
./film-exif-installer.sh ./my_photos

# 處理菲林相片，並以來源目錄名稱自動在 Google Photos 建立相簿上傳
film ./my_photos auto

# 處理菲林相片，並強制將所有相片上傳至雲端名為 "Leica MP 2026" 的相簿（直接輸入名稱即可，無需加 ""）
film ./my_photos Leica MP 2026

# ----------------------------------------------------
# 範例 B：修正 Sony HIF/HEIC 相片方向
# ----------------------------------------------------
# 僅遞迴修正本地端子資料夾內所有 HIF 檔的方向屬性
./fix-sony-hif-orientation.sh /Users/jeffreychu/Pictures/SonyPics

# 遞迴修正方向，並依據子資料夾名稱自動在 Google Photos 分相簿上傳
./fix-sony-hif-orientation.sh /Users/jeffreychu/Pictures/SonyPics auto

# 遞迴修正方向，並強制全部同步至雲端名為 "Sony A7S3 Raw Backups" 的相簿
./fix-sony-hif-orientation.sh /Users/jeffreychu/Pictures/SonyPics "Sony A7S3 Raw Backups"
```

### 🏷️ 建議：設定 `film` 命令別名

為方便在任何目錄下快速執行，建議在 `~/.zshrc` 中加入以下 alias：

```shell
alias film="/path/to/exif-shell-script/film-exif-installer.sh"
```

加入後執行 `source ~/.zshrc` 即可生效。之後在任何路徑下直接輸入 `film <目錄> <相簿>` 即可運作。

## 🛠️ 工具詳細說明與操作指南

### 1. 菲林中繼資料寫入暨命名工具 (`film-exif-installer.sh`)

此腳本專為底片掃描後的數位檔案（支援 `.jpg`, `.jpeg`, `.png`, `.tiff`, `.dng` 格式）設計。透過終端機互動式問答，補全傳統相機無法記錄的 EXIF 欄位並規範檔名。

#### 💡 核心自動化邏輯

- **動態選單與自訂輸入**：
  - **作者 (Artist)**：內建 `Jeffrey Chu`、`Roger Chan`，支援 Free text 自訂輸入。
  - **相機與鏡頭連動**：內建 `Leica MP`（連動 Summarit-M 35mm 等鏡頭）與 `Olympus OM-2Sp`（連動 Zuiko 50mm），亦支援完全自訂相機 Make/Model 及鏡頭焦距、最大光圈。
  - **底片型號與 ISO 聯動**：內建 23 款常見底片（Kodak, Fujifilm, CineStill, Ilford 等）。選擇內建底片會自動帶入標準 ISO；選自訂底片則觸發 ISO 輸入提示。
  - **沖掃紀錄**：內建香港主流沖掃工作室（DOT-WELL, Megatoni, TrueFace Pro Lab 金鈿, Photo Garden, HK Camera, Showa, Colorluxe, Lucky, Fiona）及自訂程序、曝光處理（Push/Pull）與掃描器型號。
- **自訂時間基準與每張相片精準遞增 1 分鐘機制**：
  - 每個拍攝日期分段皆獨立詢問基準開始時間（支援 `HH:MM` 或 `HHMM` 格式，例如 `14:30` 或 `1430`），若不輸入則預設由 `12:00` 開始。
  - **時間防錯排序**：為避免全卷相片因時間相同導致排序錯亂，每處理一張相片，時間戳記會**自動精準遞增 1 分鐘**，並強制寫入 `+08:00` 時區。
  - **多日期分段**：支援同一資料夾內相片跨越不同拍攝日期。可指定「第 M 張至第 N 張為同一天」，每段獨立設定日期與起始時間。直接 Enter 會自動將範圍設為最後一張。
- **設定確認與編號返回修改機制**：完成所有設定後顯示完整摘要，並列出每個區段對應的修改編號（1=作者, 2=相機+鏡頭, 3=菲林+ISO, 4=沖掃公司, 5=沖洗技術, 6=曝光處理, 7=掃描器, 8=日期與時間）。輸入對應數字即可返回修改該區段，無需重新填寫全部選項。確認無誤後按 Enter 開始處理。

#### ⚠️ 當前代碼命名規則限制說明

重新命名後的檔案結構實際上**僅由底片型號、拍攝日期時間與流水號組成**：

```text
[底片駝峰字串]_[拍攝年月日時分]_[雙位數流水號].[原副檔名]
```

### 2. Sony HIF 方向修正工具 (`fix-sony-hif-orientation.sh`)

部分看圖軟體或作業系統無法正確識別 Sony 相機產生的 .hif 或 .heic 檔案的旋轉角度。此腳本利用 ExifTool 批次讀取 CameraOrientation 中繼資料，並強制覆寫至標準的 Orientation 欄位中。

#### 💡 核心自動化邏輯

- 自動過濾系統產生的暫存檔（如 .\_ 開頭的檔案）。
- 僅針對 .hif, .HIF, .heic, .HEIC 進行批次靜默處理 (-q -q)。
- 直接覆寫原始檔案 (-overwrite_original)。

## 🔒 Git 安全規範與環境部署

由於上傳組態涉及與 Google API 連動的私密憑證（OAuth Tokens），推送到遠端儲存庫前必須嚴格遵守安全規範。

### 1. 本地環境初始化

本專案已在 `.gitignore` 中設定了 `gphotos-config/*` 的全面隔離，僅放行範本檔案。首次使用或部署到新環境時，請依據以下步驟建立你的實體私密設定：

1. 進入 `gphotos-config/` 目錄。
2. 複製 `config.example.hjson` 並重新命名為 `config.hjson`。
3. 打開 `config.hjson`，將你在 Google Cloud 申請到的專屬 `ClientID` 與 `ClientSecret` 填入。

### 2. 安全清理指令（防憑證意外洩漏）

如果在設定 `.gitignore` 前，曾不小心執行過 `git add .`，授權檔案可能已進入 Git 暫存區。請在 Push 前執行以下指令強制清除 Git 歷史快取（此操作不會刪除你本機的實體檔案）：

```bash
git rm -r --cached gphotos-config/tokens/ 2>/dev/null
git rm -r --cached gphotos-config/uploaded_files/ 2>/dev/null
git rm -r --cached gphotos-config/ongoing_uploads/ 2>/dev/null
git rm --cached gphotos-config/config.hjson 2>/dev/null
```

### 🔑 附錄：如何免費申請專屬 Google OAuth 憑證

若在執行驗證時遇到 `401` 或 `403` 錯誤，代表需要為個人帳戶配置私有憑證。請展開下方說明進行設定：

<details>
<summary>⚙️ 點擊展開查看完整 Google Cloud 設定步驟</summary>

1. **建立 Google Cloud 專案**
   - 登入 [Google Cloud Console](https://console.cloud.google.com/)。
   - 點擊左上角專案下拉選單 -> 選擇 **「新建專案 (New Project)」**，命名為 `My-Photos-Uploader` 並建立。

2. **啟用 Google Photos API**
   - 確保選中正確的專案，在上方搜尋欄輸入 **「Google Photos Library API」**。
   - 點選進入並點擊 **「啟用 (Enable)」**。

3. **設定 Google Auth Platform (OAuth 同意畫面)**
   - 點擊左側選單的 **「Branding」**（或 OAuth consent screen）。
   - 填寫 `App name`、`User support email` 與 `Developer contact information`。
   - **User type** 選擇 **External (外部)**。

4. **⚠️ 設定測試使用者（防止 403 錯誤的核心步驟）**
   - 點擊左側選單的 **「Audience」**（或拉到 Test users 頁面）。
   - 點擊 **「+ Add Users」**，**務必手動輸入並加入你準備用來上傳相片的 Google 帳號 Email**。
   - ⚠️ **重要**：加入後必須拉到頁面最下方，點擊 **「Save」** 或 **「Save and Continue」** 進行儲存，否則名單不會生效。

5. **建立與下載客戶端憑證**
   - 點擊左側選單的 **「Clients」**（或 Credentials）。
   - 點擊 **「Create Client」** (或 Create Credentials -> OAuth client ID)。
   - **Application type (應用程式類型)**：務必選擇 **「Desktop app (電腦應用程式)」**。
   - 建立完成後，在清單內點擊 **「Download JSON」** 圖示將憑證下載至本機。
   - 將下載的 JSON 內容或字串分別填入本地 `gphotos-config/config.hjson` 的 `ClientID` 與 `ClientSecret` 欄位中。

</details>
