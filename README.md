# Exif Shell Script 工具集

本專案提供一組用於處理相片 EXIF 中繼資料、自動重新命名與雲端同步上傳的 Zsh 腳本工具。專案採用極簡架構，將核心功能收斂為兩大工具，並全面整合 Google Photos 雲端備份自動化流程。

---

## 📂 專案結構與檔案總覽

```text
exif-shell-script/
├── .gitignore                  # Git 忽略設定（自動隔離私密憑證與本地快取）
├── README.md                   # 本說明文件
├── film-exif-installer.sh      # 菲林中繼資料批次寫入暨命名工具（整合上傳功能）
├── fix-sony-hif-orientation.sh # Sony HIF/HEIC 方向遞迴修正工具（整合上傳功能）
└── gphotos-config/             # 🪺 Google Photos 同步配置專用資料夾
    ├── config.example.hjson    # 設定檔範本（可公開推至 GitHub）
    ├── config.hjson            # 實體私密設定檔（安全隔離，Git 自動忽略）
    ├── tokens/                 # Google OAuth 授權憑證快取（Git 自動忽略）
    ├── uploaded_files/         # 已成功上傳的檔案去重資料庫（Git 自動忽略）
    └── ongoing_uploads/        # 斷點續傳暫存快取區（Git 自動忽略）
```

### 📋 核心檔案功能一覽

| 腳本/檔案名稱                 | 主要用途                                              | 核心特性                                                                                     |
| :---------------------------- | :---------------------------------------------------- | :------------------------------------------------------------------------------------------- |
| `film-exif-installer.sh`      | 批次寫入菲林中繼資料與自動重新命名                    | 互動式選單、自動對應 ISO、相片時間每張遞增 1 分鐘、卷號小時自動推移、選填一鍵同步上傳。      |
| `fix-sony-hif-orientation.sh` | 批次修正 Sony 相機 `.hif` / `.heic` 的檔案旋轉角度    | **全面遞迴（Recursive）**深入所有子資料夾、提取原始相機方向寫入標準 EXIF、選填一鍵同步上傳。 |
| `gphotos-config/`             | 集中收納所有與 Google Photos 上傳相關的組態與本機暫存 | 實行「單一事實來源」架構。腳本執行時會自動動態重寫此目錄下的 `config.hjson`，無須手動介入。  |

## 🛠️ 統一命令列參數使用指南

兩大腳本皆採用完全一致的參數設計，同時支援「相對路徑」與「絕對路徑」。透過第二參數，可動態決定是否觸發 Google Photos 自動同步。

### 📖 參數組合與雲端行為對照表

| 使用場景模式                                | 第二參數輸入範例     | `config.hjson` 欄位動態重寫結果                                     | Google Photos 雲端相簿實際行為                                                   |
| :------------------------------------------ | :------------------- | :------------------------------------------------------------------ | :------------------------------------------------------------------------------- |
| **1. 純本地處理**<br>（不上傳雲端）         | _不填寫第二參數_     | _不觸發上傳流程，不改寫設定檔_                                      | 僅完成本地端相片的 EXIF 寫入、重新命名或方向修正，適合本機歸檔。                 |
| **2. 動態自動分類**<br>（依子資料夾建相簿） | **`auto`**           | `SourceFolder: "/.../實體路徑"`<br>`Album: "template:%_directory%"` | 自動依據相片所在的**最內層子資料夾名稱**，在雲端各自建立對應名稱的相簿進行分類。 |
| **3. 強制指定相簿**<br>（全數塞入特定相簿） | **`"自訂相簿名稱"`** | `SourceFolder: "/.../實體路徑"`<br>`Album: "name:自訂相簿名稱"`     | 忽略任何子資料夾結構，強制將該路徑下所有相片打包上傳至雲端指定名稱的單一相簿中。 |

### 💻 指令執行範例

```shell
# ----------------------------------------------------
# 範例 A：處理菲林相片
# ----------------------------------------------------
# 僅進行本地 EXIF 寫入與重新命名
./film-exif-installer.sh ./my_photos

# 處理菲林相片，並依據子資料夾名稱自動在 Google Photos 分相簿上傳
./film-exif-installer.sh ./my_photos auto

# 處理菲林相片，並強制將所有相片上傳至雲端名為 "Leica MP 2026" 的相簿
./film-exif-installer.sh ./my_photos "Leica MP 2026"

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
