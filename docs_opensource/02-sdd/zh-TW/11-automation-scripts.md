# 11. 自動化腳本工具鏈 (Automation Scripts)

## 1. Google Play 圖書與語音有聲書發布工具鏈
- **`fetch_firestore_books.py`**: 從 Cloud Firestore 提取已審核通過之完整考題與拓撲圖檔。
- **`build_ccna_epub.py`**: 編譯符合 EPUB 3 標準之電子書，內建語音無障礙導讀標籤。
- **`publish_to_play_books.py`**: 產出 ONIX 3.0 中繼資料並批次發布至 Google Play Books。

## 2. RAG 教科書知識庫提煉工具鏈
- **`extract_gcs_rag_knowledge.py`**: 提煉 6,688 個去雜訊切片並上傳至 Google Cloud Storage。
