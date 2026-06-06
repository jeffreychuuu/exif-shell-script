# Exif Shell Script 工具集

本專案提供一組用於處理相片 EXIF 中繼資料與自動重新命名的 Shell 腳本工具，特別適合菲林（底片）愛好者在管理與歸檔數位掃描檔案時使用。

## 📂 檔案清單與功能總覽

| 腳本名稱                      | 檔案類型   | 主要用途                                       | 核心特性                                                                    |
| :---------------------------- | :--------- | :--------------------------------------------- | :-------------------------------------------------------------------------- |
| `film-exif-installer.sh`      | Zsh 腳本   | 批次寫入菲林中繼資料與重新命名                 | 互動式選單、自動換算 ISO、時間每張遞增 1 分鐘、駝峰式命名、強制 +08:00 時區 |
| `fix-sony-hif-orientation.sh` | Shell 腳本 | 修正 Sony 相機 `.hif` / `.heic` 檔案的方向屬性 | 將 `CameraOrientation` 寫入標準 `Orientation`，解決旋轉顯示錯誤             |
| `.gitignore`                  | 設定檔     | 排除無需納入版本控制的環境暫存檔               | 預設忽略 `.history` 與 `.DS_Store`                                          |

---

## 📋 系統環境需求

- **環境需求**：macOS / Linux (腳本基於 `#!/bin/zsh` 撰寫)
- **必備依賴**：[ExifTool](https://exiftool.org/)
  - 腳本內預設的 ExifTool 執行路徑為 `/opt/homebrew/bin/exiftool` (macOS Homebrew 預設路徑)。若在其他系統或路徑下運行，請手動修改腳本內的調用路徑。

---

## 🛠️ 工具詳細說明與操作指南

### 1. 菲林中繼資料寫入暨命名工具 (`film-exif-installer.sh`)

此腳本專為底片掃描後的數位檔案（支援 `.jpg`, `.jpeg`, `.png`, `.tiff`, `.dng` 格式）設計。透過終端機互動式問答，一鍵補全傳統相機無法記錄的 EXIF 欄位。

#### 💡 核心自動化邏輯

- **作者欄位 (Author/Artist)**：內建 `Jeffrey Chu`、`Roger Chan`、`Tracy Tong` 快速選項，預設為 `Jeffrey Chu`。
- **鏡頭規格 (Lens)**：內建常用 Leica 鏡頭（35mm f/2.5、28mm f/2.8），支援自訂手動輸入鏡頭型號、焦距與最大光圈。
- **底片型號與 ISO 聯動 (Film Stock & ISO)**：內建 10 款常見底片（Kodak Ultramax/Gold/Portra、Cinestill、Ilford 等），選擇後自動代入正確 ISO 值；選擇自訂底片時會自動觸發 ISO 手動輸入提示。
- **沖掃店鋪紀錄 (Lab)**：內建香港主流沖掃工作室（DOT-WELL, Megatoni, TrueFace Pro Lab, Photo Garden, HK Camera, Showa, Colorluxe）及自訂選項。
- **相機基礎設定**：預設相機製造商為 `Leica Camera AG`，型號預設為 `Leica MP`（支援手動覆蓋）。
- **拍攝時間遞增機制**：為避免全卷相片因時間完全相同導致排序錯亂，腳本將以中午 `12:00:00` 為基準點，**每處理一張相片自動精準遞增 1 分鐘**（如：12:00, 12:01, 12:02 ...），並支援自動進位至小時。同時強制寫入 `+08:00` 時區。
- **標準化檔名規則**：處理完成後，檔案會依據以下結構自動重新命名：
  `[鏡頭駝峰字串]_[底片駝峰字串]_[作者駝峰字串]_[年月日]_[雙位數流水號].[副檔名]`
  _範例：`LeicaSummaritM35mmF25_KodakUltramax400_JeffreyChu_20260606_01.jpg`_

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
