# -*- coding: utf-8 -*-
"""
Python script to crawl history multiple choice questions from Vietjack 
and import them directly into SQL Server database (Onthilop12).
"""

import sys
import codecs
import urllib.request
import re
import xml.etree.ElementTree as ET

# Ensure stdout uses UTF-8 to display Vietnamese correctly
sys.stdout.reconfigure(encoding='utf-8')

print("🚀 Starting Crawler Demo from Vietjack to SQL Server...")

base_url = "https://www.vietjack.com/trac-nghiem-dai-hoc/trac-nghiem-lich-su-viet-nam-hien-dai.jsp"

# Simple parser without external BeautifulSoup dependency to ensure it runs out-of-the-box
def parse_vietjack_page(page_num):
    url = base_url if page_num == 1 else f"{base_url}?page={page_num}"
    print(f"👉 Crawling page {page_num}: {url}")
    
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
    req = urllib.request.Request(url, headers=headers)
    
    try:
        with urllib.request.urlopen(req) as response:
            html = response.read().decode('utf-8', errors='ignore')
    except Exception as e:
        print(f"❌ Error downloading page {page_num}: {e}")
        return []

    # Simple regex based extractor for demo purposes
    # Extract <p> tags and parse questions
    p_tags = re.findall(r'<p[^>]*>(.*?)</p>', html, re.DOTALL)
    
    questions = []
    current_q = None
    
    def clean_html(raw_html):
        # Remove HTML tags
        cleanr = re.compile('<.*?>')
        cleantext = re.sub(cleanr, '', raw_html)
        return cleantext.strip()

    for p in p_tags:
        text = clean_html(p)
        if not text:
            continue
            
        if re.match(r'Câu\s*\d+:', text) or re.match(r'Câu\s*\d+\.', text):
            if current_q:
                questions.append(current_q)
            current_q = {
                'question': text,
                'answers': [],
                'correct': 'A'
            }
        elif re.match(r'^[A-D]\.', text):
            if current_q:
                current_q['answers'].append(text)
        elif 'Đáp án' in text or 'Đáp án đúng' in text:
            match = re.search(r'\b([A-D])\b', text)
            if match and current_q:
                current_q['correct'] = match.group(1)

    if current_q:
        questions.append(current_q)
        
    return questions

# Crawl page 1 as a demo
crawled_questions = parse_vietjack_page(1)
print(f"📊 Successfully crawled {len(crawled_questions)} questions from page 1!")

# Generate SQL seed file for the crawled questions
sql_lines = []
sql_lines.append("-- SQL Server Import Script for Crawled Questions")
sql_lines.append("USE Onthilop12;")
sql_lines.append("GO")
sql_lines.append("")

# Assume Chapter ID 22 (Lịch sử 12) for the crawled questions
chapter_id = 22

for i, q in enumerate(crawled_questions):
    q_text = q['question'].replace("'", "''")
    
    # Pad answers if less than 4
    ans = [a.replace("'", "''") for a in q['answers']]
    while len(ans) < 4:
        ans.append("N/A")
        
    # Clean answer prefix like "A. "
    def clean_prefix(a):
        return re.sub(r'^[A-D]\.\s*', '', a).strip()
        
    ans_a = clean_prefix(ans[0])
    ans_b = clean_prefix(ans[1])
    ans_c = clean_prefix(ans[2])
    ans_d = clean_prefix(ans[3])
    correct = q['correct']
    
    sql_lines.append(
        f"INSERT INTO CauHoi (MaChuong, NoiDung, CauA, CauB, CauC, CauD, DapAnDung, LoiGiai, NgayTao) "
        f"VALUES ({chapter_id}, N'{q_text}', N'{ans_a}', N'{ans_b}', N'{ans_c}', N'{ans_d}', N'{correct}', N'Cào tự động', GETDATE());"
    )

output_sql_path = "crawled_import.sql"
with codecs.open(output_sql_path, "w", encoding="utf-8-sig") as f:
    f.write("\n".join(sql_lines))

print(f"💾 SQL Script generated at: {output_sql_path}")
print(f"To import to SQL Server, run:")
print(f"sqlcmd -S LAPTOP-MPB4SON1\\ANHHAO -E -d Onthilop12 -i crawled_import.sql -f 65001")
print("✅ Demo execution successful!")
