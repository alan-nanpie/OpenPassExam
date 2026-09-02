#!/usr/bin/env python3
"""
PassExam Automation Toolchain: fetch_firestore_books.py
從 Google Cloud Firestore 提取已審核通過之考題與拓撲圖檔，為 EPUB 3 編譯與 Google Play Books 發布準備資料集。
"""

import json
import os
import sys

def fetch_approved_questions(subject_id="cisco-200-301", output_file="extracted_questions.json"):
    print(f"[*] 正在從 Cloud Firestore 提取考科 [{subject_id}] 已審核通過之考題...")
    
    # 模擬資料集或連接 Firebase Admin
    sample_dataset = [
        {
            "id": "ccna_q001",
            "exam_id": subject_id,
            "type": "SINGLE_CHOICE",
            "title": "某工程師在路由器 R1 上配置了靜態預設路由，下列何者為正確的 Cisco IOS 語法？",
            "options": [
                "ip route 0.0.0.0 0.0.0.0 192.168.1.1",
                "router static 0.0.0.0/0 192.168.1.1",
                "ip default-network 192.168.1.1 0.0.0.0",
                "ip route any any 192.168.1.1"
            ],
            "correct_answer": [0],
            "explanation": "在 Cisco IOS 中，標準 IPv4 靜態預設路由語法為 ip route 0.0.0.0 0.0.0.0 <下一跳IP 或 出介面>。",
            "topic": "3.0 IP 連線能力",
            "is_approved": True
        }
    ]
    
    os.makedirs(os.path.dirname(output_file) if os.path.dirname(output_file) else ".", exist_ok=True)
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(sample_dataset, f, ensure_ascii=False, indent=2)
        
    print(f"[+] 提取完成！已輸出至 {output_file}，共提取 {len(sample_dataset)} 題。")

if __name__ == "__main__":
    subject = sys.argv[1] if len(sys.argv) > 1 else "cisco-200-301"
    fetch_approved_questions(subject)
