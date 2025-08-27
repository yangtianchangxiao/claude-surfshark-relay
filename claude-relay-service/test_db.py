#!/usr/bin/env python3
import sqlite3
import os

# 数据库文件绝对路径
DB_PATH = "/home/ubuntu/web3/prediction-market-mvp/backend/prediction_market.db"

print(f"1. 检查数据库文件是否存在: {os.path.exists(DB_PATH)}")

try:
    # 连接到数据库
    print(f"2. 尝试连接数据库...")
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # 列出所有表
    print("3. 查询所有表...")
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = cursor.fetchall()
    print(f"4. 数据库中的表: {tables}")
    
    # 查询users表结构
    print("5. 查询users表结构...")
    cursor.execute("PRAGMA table_info(users)")
    columns = cursor.fetchall()
    print(f"6. users表列结构: {columns}")
    
    # 查询用户数据
    print("7. 查询用户数据...")
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    print(f"8. 用户数据: {users}")
    
    conn.close()
    print("9. 数据库连接关闭")
except Exception as e:
    print(f"错误: {e}")
    import traceback
    traceback.print_exc() 