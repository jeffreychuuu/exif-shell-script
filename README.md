# Exif Shell Script 工具集

本專案提供一組用於處理相片 EXIF 中繼資料與自動重新命名的 Zsh / Shell 腳本，特別針對菲林（底片）數位化歸檔流程與 Sony HIF 檔案方向修正進行優化。

## 📂 檔案清單與功能總覽

| 腳本名稱                      | 檔案類型                | 主要用途                                       | 核心特性                                                                                           |
| :---------------------------- | :---------------------- | :--------------------------------------------- | :------------------------------------------------------------------------------------------------- |
| `film-exif-installer.sh`      | Zsh 腳本 (`#!/bin/zsh`) | 批次寫入菲林中繼資料與重新命名                 | 互動式選單、底片與 ISO 連動、自訂時間基準、卷號自動推移小時、時間每張遞增 1 分鐘、強制 +08:00 時區 |
| `fix-sony-hif-orientation.sh` | Shell 腳本              | 修正 Sony 相機 `.hif` / `.heic` 檔案的方向屬性 | 將 `CameraOrientation` 寫入標準 `Orientation`，解決特定看圖軟體旋轉顯示錯誤                        |
| `.gitignore`                  | 設定檔                  | 排除無需納入版本控制的環境暫存檔               | 預設忽略 `.history` 與 `.DS_Store`                                                                 |

---

## 📋 系統環境需求

- **環境需求**：macOS / Linux (腳本基於 `#!/bin/zsh` 撰寫)
- **必備依賴**：[ExifTool](https://exiftool.org/)
  - 腳本內預設的 ExifTool 執行路徑為 `/opt/homebrew/bin/exiftool` (macOS Homebrew 預設路徑)。若在其他系統或路徑下運行，請自行修改腳本內的調用路徑。

---

## 🛠️ 工具詳細說明與操作指南

### 1. 菲林中繼資料寫入暨命名工具 (`film-exif-installer.sh`)

此腳本專為底片掃描後的數位檔案（支援 `.jpg`, `.jpeg`, `.png`, `.tiff`, `.dng` 格式）設計。透過終端機互動式問答，補全傳統相機無法記錄的 EXIF 欄位並規範檔名。

#### 💡 核心自動化邏輯

- **動態選單與自訂輸入**：
  - **作者 (Artist)**：內建 `Jeffrey Chu`、`Roger Chan`、`Tracy Tong`，支援 Free text 自訂輸入。
  - **相機與鏡頭連動**：內建 `Leica MP`（連動 Summarit-M 35mm 等鏡頭）與 `Olympus OM-2Sp`（連動 Zuiko 50mm），亦支援完全自訂相機 Make/Model 及鏡頭焦距、最大光圈。
  - **底片型號與 ISO 聯動**：內建 23 款常見底片（Kodak, Fujifilm, CineStill, Ilford 等）。選擇內建底片會自動帶入標準 ISO；選自訂底片則觸發 ISO 輸入提示。
  - **沖掃紀錄**：內建香港主流沖掃工作室（DOT-WELL, Megatoni, TrueFace Pro Lab 金鈿, Photo Garden, HK Camera, Showa, Colorluxe, Lucky, Fiona）及自訂程序、曝光處理（Push/Pull）與掃描器型號。
- **自訂時間基準與卷號遞增機制**：
  - 支援互動式選取是否手動輸入基準開始時間（格式 `HH:MM`），若不輸入則預設由 `12:00` 開始。
  - **卷號小時推移**：啟始小時會依卷號（Roll Number）自動疊加推移，公式為：`BASE_HOUR = 設定小時 + ROLL_NUM - 1`。例如設定 12 點開始，第 2 卷會自動從 13 點開始。
  - **時間防錯排序**：為避免全卷相片因時間相同導致排序錯亂，每處理一張相片，時間戳記會**自動精準遞增 1 分鐘**，並強制寫入 `+08:00` 時區。

#### ⚠️ 當前代碼命名規則限制說明

重新命名後的檔案結構實際上**僅由底片型號、卷號、日期與流水號組成**：

```text
[底片駝峰字串]_[卷號字串]_[拍攝年月日]_[雙位數流水號].[原副檔名]
```

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

# 執行腳本 (預設處理當前目錄)
./fix-sony-hif-orientation.sh
```
