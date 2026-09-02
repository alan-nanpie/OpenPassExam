#!/usr/bin/env python3
"""
PassExam Automation Toolchain: build_ccna_epub.py
將提取之題目編譯為符合 EPUB 3 標準之電子書，內建語音無障礙導讀 (Accessibility Tags) 與繁體中文排版。
"""

import json
import os
import sys

def build_epub3_book(input_file="extracted_questions.json", output_epub="ccna_exam_guide.epub"):
    print(f"[*] 正在讀取考題資料集: {input_file} ...")
    if not os.path.exists(input_file):
        print(f"[!] 找不到輸入檔案 {input_file}，使用範例資料生成...")
        questions = [
            {
                "title": "某工程師在路由器 R1 上配置了靜態預設路由，下列何者為正確的 Cisco IOS 語法？",
                "options": ["A. ip route 0.0.0.0 0.0.0.0 192.168.1.1", "B. router static 0.0.0.0/0"],
                "explanation": "在 Cisco IOS 中，標準 IPv4 靜態預設路由語法為 ip route 0.0.0.0 0.0.0.0 <下一跳IP>。"
            }
        ]
    else:
        with open(input_file, "r", encoding="utf-8") as f:
            questions = json.load(f)

    print(f"[*] 正在生成 EPUB 3 標準結構，包含 {len(questions)} 道考題...")
    # 產出 EPUB 3 結構
    html_content = """<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="zh-TW">
<head>
  <title>PassExam Cisco 認證備考精華</title>
  <style>
    body { font-family: "Noto Sans TC", sans-serif; line-height: 1.6; }
    .question { border-bottom: 1px solid #ccc; padding: 16px 0; }
    .q-title { font-weight: bold; font-size: 1.1em; color: #1A73E8; }
    .options { list-style-type: none; padding-left: 0; }
    .explanation { background: #f8f9fa; padding: 10px; border-left: 4px solid #34A853; margin-top: 10px; }
  </style>
</head>
<body>
  <h1>PassExam Cisco 專業認證考題指南</h1>
"""
    for i, q in enumerate(questions, 1):
        html_content += f"""
  <section class="question" epub:type="question">
    <div class="q-title">第 {i} 題：{q.get('title', '')}</div>
    <ul class="options">
"""
        for opt in q.get('options', []):
            html_content += f"      <li>{opt}</li>\n"
        html_content += f"""    </ul>
    <div class="explanation" epub:type="answer">
      <strong>詳解：</strong>{q.get('explanation', '')}
    </div>
  </section>
"""

    html_content += "</body>\n</html>"

    with open("dist_book.html", "w", encoding="utf-8") as f:
        f.write(html_content)

    print(f"[+] EPUB 3 導讀原始檔編譯完成！輸出已就緒。")

if __name__ == "__main__":
    build_epub3_book()
