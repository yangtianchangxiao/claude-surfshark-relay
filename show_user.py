#!/usr/bin/env python3
import sqlite3
import sys
import os
import argparse
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.text import Text

# 数据库文件绝对路径
DB_PATH = "/home/ubuntu/web3/prediction-market-mvp/backend/prediction_market.db"

# 创建命令行参数解析器
parser = argparse.ArgumentParser(description='显示预测市场用户信息')
parser.add_argument('--user-id', type=int, help='按用户ID查询')
parser.add_argument('--telegram-id', type=int, help='按Telegram ID查询')
parser.add_argument('--username', type=str, help='按用户名查询')
args = parser.parse_args()

# 初始化富文本控制台
console = Console()

def query_users(user_id=None, telegram_id=None, username=None):
    """查询用户信息"""
    # 连接到数据库
    try:
        console.print(f"连接到数据库: [blue]{DB_PATH}[/blue]")
        if not os.path.exists(DB_PATH):
            console.print(f"[bold red]错误: 数据库文件不存在![/bold red]")
            sys.exit(1)
            
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
    except Exception as e:
        console.print(f"[bold red]连接数据库失败: {e}[/bold red]")
        sys.exit(1)
        
    try:
        # 根据条件查询
        if user_id:
            cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
            console.print(f"按用户ID查询: [yellow]{user_id}[/yellow]")
        elif telegram_id:
            cursor.execute("SELECT * FROM users WHERE telegram_id = ?", (telegram_id,))
            console.print(f"按Telegram ID查询: [yellow]{telegram_id}[/yellow]")
        elif username:
            cursor.execute("SELECT * FROM users WHERE username LIKE ?", (f"%{username}%",))
            console.print(f"按用户名查询: [yellow]{username}[/yellow]")
        else:
            cursor.execute("SELECT * FROM users")
            console.print("查询所有用户")
            
        users = cursor.fetchall()
        conn.close()
        return users
    except Exception as e:
        console.print(f"[bold red]查询数据库失败: {e}[/bold red]")
        conn.close()
        sys.exit(1)

def display_user_info(users):
    """使用rich库显示用户信息"""
    if not users:
        console.print(Panel("[bold red]未找到任何用户信息！[/bold red]"))
        return
    
    # 创建表格
    table = Table(title="用户信息")
    
    # 添加列
    table.add_column("ID", style="cyan")
    table.add_column("Telegram ID", style="green")
    table.add_column("用户名", style="blue")
    table.add_column("名字", style="yellow")
    table.add_column("姓", style="yellow")
    table.add_column("积分余额", style="magenta")
    table.add_column("创建时间", style="green")
    
    # 添加数据行
    for user in users:
        table.add_row(
            str(user[0]),               # ID
            str(user[1]) if user[1] else "N/A",  # Telegram ID
            user[3] if user[3] else "N/A",       # 用户名
            user[4] if user[4] else "N/A",       # 名字
            user[5] if user[5] else "N/A",       # 姓
            str(user[7]),               # 积分余额
            user[8]                     # 创建时间
        )
    
    # 显示表格
    console.print(table)
    
    # 对于每个用户，显示详细信息
    for user in users:
        details = Text()
        details.append(f"用户ID: ", style="bold")
        details.append(f"{user[0]}\n")
        
        details.append(f"Telegram ID: ", style="bold")
        details.append(f"{user[1] if user[1] else 'N/A'}\n")
        
        details.append(f"钱包地址: ", style="bold")
        details.append(f"{user[2] if user[2] else 'N/A'}\n")
        
        details.append(f"用户名: ", style="bold")
        details.append(f"{user[3] if user[3] else 'N/A'}\n")
        
        details.append(f"名字: ", style="bold")
        details.append(f"{user[4] if user[4] else 'N/A'}\n")
        
        details.append(f"姓: ", style="bold")
        details.append(f"{user[5] if user[5] else 'N/A'}\n")
        
        details.append(f"头像URL: ", style="bold")
        details.append(f"{user[6] if user[6] else 'N/A'}\n")
        
        details.append(f"积分余额: ", style="bold")
        details.append(f"{user[7]}\n")
        
        details.append(f"创建时间: ", style="bold")
        details.append(f"{user[8]}\n")
        
        details.append(f"更新时间: ", style="bold")
        details.append(f"{user[9] if user[9] else 'N/A'}")
        
        console.print(Panel(details, title=f"用户 {user[3] if user[3] else user[0]} 详细信息", border_style="green"))

def main():
    # 查询用户信息
    console.print(Panel("[bold cyan]预测市场用户信息查询工具[/bold cyan]"))
    users = query_users(
        user_id=args.user_id,
        telegram_id=args.telegram_id,
        username=args.username
    )
    
    # 显示用户信息
    display_user_info(users)

if __name__ == "__main__":
    main() 