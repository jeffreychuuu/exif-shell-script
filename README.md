# Exif Shell Script 工具集

本專案提供一組用於處理相片 EXIF 中繼資料、自動重新命名與雲端同步上傳的 Shell 腳本工具，特別針對菲林（底片）數位化歸檔與 Sony HIF/HEIC 檔案方向修正及 Google Photos 自動化備份流程進行全面優化。

## 📂 檔案清單與功能總覽

| 腳本/檔案名稱                 | 檔案類型   | 主要用途                                           | 核心特性                                                                                                                            |
| :---------------------------- | :--------- | :------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
| `film-exif-installer.sh`      | Zsh 腳本   | 批次寫入菲林中繼資料與重新命名                     | 互動式選單、自動對應 ISO、時間每張遞增 1 分鐘、支援自訂時間基準與卷號小時自動推移、支援相對/絕對路徑。                              |
| `fix-sony-hif-orientation.sh` | Zsh 腳本   | 批次修正 Sony 相機 `.hif` / `.heic` 檔案的方向屬性 | 支援指定「相對/絕對路徑」、自動**遞迴（Recursive）**掃描子資料夾，將 `CameraOrientation` 寫入標準 `Orientation`。                   |
| `fix-and-upload-sony-hif.sh`  | Zsh 腳本   | 一鍵完成「方向修正」與「Google Photos 備份」       | 專案終極自動化工具。自動轉絕對路徑並動態覆寫 `config.hjson` 內的 `SourceFolder` 欄位，完成遞迴方向修正後自動呼叫 CLI 進行同步上傳。 |
| `config.example.hjson`        | 設定檔範本 | 提供 `gphotos-uploader-cli` 的設定結構參考         | 欄位完全符合官方新版規範（使用 `SourceFolder` 與 `Album`），預設組態動態相簿範本。                                                  |
| `.gitignore`                  | 設定檔     | 排除環境暫存與私密憑證                             | 強制隔離 `config.hjson`、`tokens/`、`uploaded_files/` 及 `ongoing_uploads/`，防止隱私洩漏。                                         |

---

## 📋 系統環境與相依性需求

- **環境需求**：macOS / Linux (腳本基於 `#!/bin/zsh` 撰寫)
- **工具相依性**：
  1. [ExifTool](https://exiftool.org/)：腳本內預設執行路徑為 `/opt/homebrew/bin/exiftool`。
  2. [gphotos-uploader-cli](https://github.com/gphotosuploader/gphotos-uploader-cli)：用於執行 Google Photos 雲端無感同步上傳。

---

## 🛠️ 工具詳細說明與操作指南

### 1. 菲林中繼資料寫入暨命名工具 (`film-exif-installer.sh`)

此腳本專為底片數位化掃描檔案設計。透過終端機互動式選單，規範檔名並補全傳統相機無法記錄的 EXIF 欄位。

#### 💡 核心自動化邏輯

- **支援路徑模式**：同時接受「相對路徑」與「絕對路徑」作為參數，未帶入參數則預設處理當前目錄 (`.`)。
- **時間防錯排序**：可自訂 `HH:MM` 啟始時間（預設 12:00），每張相片的時間戳記會**自動精準遞增 1 分鐘**，防範相簿排序錯亂。
- **卷號時間推移**：啟始小時會依卷號（Roll Number）自動疊加推移（公式：`實際小時 = 基準小時 + 卷號 - 1`）。
- **標準化檔名結構**：
  `[底片駝峰字串]_[卷號字串]_[拍攝年月日]_[雙位數流水號].[原副檔名]`
  _(註：鏡頭與作者變數目前僅供寫入 EXIF，不組合進檔名)_

#### 📖 執行方式

```shell
# 賦予執行權限
chmod +x film-exif-installer.sh

# 執行腳本（可帶入目標資料夾路徑，未帶入則預設為目前所在目錄 `.`）
./film-exif-installer.sh /path/to/your/photos
```

### 2. Sony HIF 方向修正工具 (`fix-sony-hif-orientation.sh`)

部分看圖軟體或作業系統無法正確識別 Sony 相機產生的 .hif 或 .heic 檔案的旋轉角度。此腳本利用 ExifTool 批次讀取 CameraOrientation 中繼資料，並強制覆寫至標準的 Orientation 欄位中。

#### 💡 核心自動化邏輯

- 自動過濾系統產生的暫存檔（如 .\_ 開頭的檔案）。
- 僅針對 .hif, .HIF, .heic, .HEIC 進行批次靜默處理 (-q -q)。
- 直接覆寫原始檔案 (-overwrite_original)。

#### 📖 執行方式

將腳本放置於相片所在目錄或於該目錄下直接執行：

```shell
# 賦予執行權限
chmod +x fix-sony-hif-orientation.sh

# 執行腳本（可帶入目標資料夾路徑，未帶入則預設為目前所在目錄 `.`）
./fix-sony-hif-orientation.sh /path/to/your/photos
```

### 3. 一體化修正上傳工具 (`fix-and-upload-sony-hif.sh`)

本專案的最強自動化模組。實現「單一事實來源（Single Source of Truth）」，你只需要指定一個目標路徑，後續的 EXIF 修正與 Google Photos 上傳路徑會完全自動同步。

#### 💡 核心自動化邏輯

路徑自動實體化：將你傳入的任何相對/絕對路徑自動轉為標準「絕對路徑」。

設定檔動態重寫：利用精確正則表達式，執行時自動將實體路徑覆寫進 `config.hjson` 內官方標準的 `SourceFolder` 欄位。

流水線作業：自動遞迴修正該路徑下所有 HIF/HEIC 相片方向，完成後靜默啟動 `gphotos-uploader-cli push` 觸發備份。

```shell
# 賦予執行權限
chmod +x fix-and-upload-sony-hif.sh

# 執行此指令，該子資料夾內的相片會完成修正，並精準同步上傳至 Google Photos
./fix-and-upload-sony-hif.sh ~/Pictures/2026_Japan_Trip
```

### ⚙️ Google Photos CLI 組態與 Git 安全規範

由於本專案涉及與 Google API 連動的私密憑證，推送到 GitHub 前必須嚴格遵守安全規範。

#### 1. 本地設定檔範本 (`config.example.hjson`)

專案中已隔離真實的 config.hjson。首次使用或在全新環境部署時，請將 config.example.hjson 複製一份並重新命名為 config.hjson，然後填入你在 Google Cloud 主機申請到的私有憑證：

```json
{
  APIAppCredentials: {
    ClientID: "你的_GOOGLE_CLIENT_ID"
    ClientSecret: "你的_GOOGLE_CLIENT_SECRET"
  }
  Account: "your_email@gmail.com"
  SecretsBackendType: "file"
  Jobs: [
    {
      SourceFolder: "./test"  // 此處路徑會被一體化腳本自動動態覆寫
      Album: "template:%_directory%"  // 自動依據相片所在的最內層子資料夾名稱在雲端分類建相簿
    }
  ]
}
```

#### 2. Git 提交注意事項（防憑證洩漏）

執行 git push 前，請務必確認本地生成的以下私密檔案/資料夾已被 Git 完全忽略：

- config.hjson (包含實體私鑰)
- tokens/ (包含個人 Google 帳戶的驗證 Token)
- uploaded_files/ 與 ongoing_uploads/ (本地同步上傳進度資料庫)
  若不慎曾將其加入暫存，請於終端機執行以下指令進行強制快取清除：

```shell
git rm -r --cached tokens/ uploaded_files/ ongoing_uploads/ config.hjson 2>/dev/null
```

### 🔑 附錄：如何免費申請專屬 Google OAuth 憑證

若在執行驗證時遇到 `401` 或 `403` 錯誤，代表需要為個人帳戶組態私有憑證。請展開下方說明進行設定：

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
   - 將下載的 JSON 內容或字串分別填入本地 `config.hjson` 的 `ClientID` 與 `ClientSecret` 欄位中。

</details>
