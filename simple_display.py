#!/usr/bin/env python3
import sqlite3

# 数据库文件绝对路径
DB_PATH = "/home/ubuntu/web3/prediction-market-mvp/backend/prediction_market.db"

def main():
    # 连接到数据库
    try:
        print(f"尝试连接数据库: {DB_PATH}")
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        print("查询数据库表...")
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = cursor.fetchall()
        print(f"数据库中的表: {tables}")
        
        print("查询用户数据...")
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
        
        print(f"找到 {len(users)} 个用户:")
        for user in users:
            print(f"ID: {user[0]}")
            print(f"Telegram ID: {user[1]}")
            print(f"用户名: {user[3]}")
            print(f"姓名: {user[4]} {user[5]}")
            print(f"积分: {user[7]}")
            print(f"创建时间: {user[8]}")
            print("------------------------")
        
        conn.close()
        print("数据库连接关闭")
    except Exception as e:
        print(f"发生错误: {e}")

if __name__ == "__main__":
    main() 