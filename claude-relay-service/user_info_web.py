#!/usr/bin/env python3
import sqlite3
import os
from flask import Flask, render_template_string, request, jsonify

app = Flask(__name__)

# 数据库文件绝对路径
DB_PATH = '/home/ubuntu/web3/prediction-market-mvp/backend/prediction_market.db'

# HTML模板 - 使用Bootstrap进行美化
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>预测市场用户信息</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f5f5;
            padding: 20px;
        }
        .card {
            margin-bottom: 20px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .user-avatar {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            margin: 0 auto;
            display: block;
            border: 3px solid #17a2b8;
        }
        .profile-header {
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            color: white;
            padding: 30px;
            border-radius: 10px 10px 0 0;
        }
        .stat-card {
            text-align: center;
            padding: 20px;
        }
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #17a2b8;
        }
        .stat-label {
            color: #6c757d;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="text-center my-4">预测市场用户信息面板</h1>
        
        <div class="row justify-content-center mb-4">
            <div class="col-md-6">
                <form method="get" class="card p-3">
                    <div class="mb-3">
                        <label for="search" class="form-label">搜索用户</label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="search" name="search" placeholder="输入用户名或Telegram ID">
                            <button type="submit" class="btn btn-primary">搜索</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        
        {% if users %}
            {% for user in users %}
            <div class="card mb-4">
                <div class="profile-header">
                    <div class="row align-items-center">
                        <div class="col-md-3">
                            {% if user.photo_url %}
                            <img src="{{ user.photo_url }}" alt="用户头像" class="user-avatar">
                            {% else %}
                            <div class="user-avatar d-flex align-items-center justify-content-center bg-secondary">
                                <span class="display-4 text-white">{{ user.username[0] if user.username else 'U' }}</span>
                            </div>
                            {% endif %}
                        </div>
                        <div class="col-md-9">
                            <h2>{{ user.username or '未设置用户名' }}</h2>
                            <p class="mb-0">{{ user.first_name or '' }} {{ user.last_name or '' }}</p>
                            <p class="text-light mb-0">用户ID: {{ user.id }}</p>
                            <p class="text-light mb-0">Telegram ID: {{ user.telegram_id or '未绑定' }}</p>
                        </div>
                    </div>
                </div>
                
                <div class="card-body">
                    <div class="row mb-4">
                        <div class="col-md-4">
                            <div class="card stat-card">
                                <div class="stat-value">{{ user.points_balance }}</div>
                                <div class="stat-label">积分余额</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card stat-card">
                                <div class="stat-value">{{ user.created_at.split(' ')[0] }}</div>
                                <div class="stat-label">注册日期</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card stat-card">
                                <div class="stat-value">{{ user.wallet_address[:6] + '...' if user.wallet_address else '未绑定' }}</div>
                                <div class="stat-label">钱包地址</div>
                            </div>
                        </div>
                    </div>
                    
                    <h4 class="mb-3">详细信息</h4>
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <tbody>
                                <tr>
                                    <th width="30%">用户ID</th>
                                    <td>{{ user.id }}</td>
                                </tr>
                                <tr>
                                    <th>Telegram ID</th>
                                    <td>{{ user.telegram_id or '未绑定' }}</td>
                                </tr>
                                <tr>
                                    <th>用户名</th>
                                    <td>{{ user.username or '未设置' }}</td>
                                </tr>
                                <tr>
                                    <th>姓名</th>
                                    <td>{{ user.first_name or '' }} {{ user.last_name or '' }}</td>
                                </tr>
                                <tr>
                                    <th>钱包地址</th>
                                    <td>{{ user.wallet_address or '未绑定' }}</td>
                                </tr>
                                <tr>
                                    <th>积分余额</th>
                                    <td>{{ user.points_balance }}</td>
                                </tr>
                                <tr>
                                    <th>注册时间</th>
                                    <td>{{ user.created_at }}</td>
                                </tr>
                                <tr>
                                    <th>最后更新</th>
                                    <td>{{ user.updated_at or '无更新记录' }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            {% endfor %}
        {% else %}
            <div class="alert alert-info text-center">
                <h4>没有找到用户信息</h4>
                <p>请尝试其他搜索条件或查看是否有用户数据</p>
            </div>
        {% endif %}
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
"""

def dict_factory(cursor, row):
    """将SQLite查询结果转换为字典"""
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

@app.route('/')
def index():
    """主页 - 显示用户信息"""
    search_term = request.args.get('search', '')
    
    # 连接到数据库
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = dict_factory
    cursor = conn.cursor()
    
    # 查询用户
    if search_term:
        # 尝试将search_term转换为整数(telegram_id)
        try:
            telegram_id = int(search_term)
            cursor.execute("SELECT * FROM users WHERE telegram_id = ?", (telegram_id,))
        except ValueError:
            # 如果不是整数，则按用户名搜索
            cursor.execute("SELECT * FROM users WHERE username LIKE ?", (f"%{search_term}%",))
    else:
        cursor.execute("SELECT * FROM users")
    
    users = cursor.fetchall()
    conn.close()
    
    return render_template_string(HTML_TEMPLATE, users=users)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000) 