from flask import Flask, request, jsonify
from pyzbar.pyzbar import decode
from PIL import Image
import io
import pymysql
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# 資料庫連線函數
def get_db():
    conn = pymysql.connect(
        host='localhost',
        user='root',
        password='930610',
        database='invoice_db',
        port=3307,
        charset='utf8mb4'
    )
    return conn

# QR Code 解碼與解析商品
def decode_qr_and_parse(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    decoded_qrs = decode(image)

    if not decoded_qrs:
        return None, "找不到 QR Code"

    # 選擇最長的 QR code 為右側
    qr_content = max(decoded_qrs, key=lambda qr: len(qr.data)).data.decode('utf-8')
    print("🧾 QR 原始內容：", qr_content)

    # 嘗試用冒號分割資料欄位（右側 QR code 有時是明文格式）
    fields = qr_content.split(':')
    items = []

    i = len(fields) - 3
    while i >= 0:
        name = fields[i]
        qty = fields[i + 1]
        price = fields[i + 2]
        try:
            if name.strip() and qty.isdigit() and price.isdigit():
                subtotal = str(int(qty) * int(price))
                items.append({
                    "name": name.strip(),
                    "qty": qty,
                    "price": price,
                    "subtotal": subtotal
                })
        except:
            pass
        i -= 3

    items.reverse()

    return {
        "header": qr_content[:10],
        "items": items
    }, qr_content

# API 路由處理
@app.route('/qr', methods=['POST'])
def handle_qr():
    print("✅ 接收到上傳")
    
    if 'image' not in request.files:
        print("❌ 沒有收到 image")
        return jsonify({'error': '請用 form-data 傳送 image'}), 400

    file = request.files['image']
    image_bytes = file.read()

    print("📥 圖片已讀取")

    parsed, raw = decode_qr_and_parse(image_bytes)
    if not parsed:
        print("❌ QR 解碼失敗")
        return jsonify({'error': raw}), 400

    print("🧾 QR 解碼成功，準備寫入資料庫")

    try:
        conn = get_db()
        with conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO invoices (invoice_number)
                    VALUES (%s)
                """, (parsed['header'],))
                invoice_id = conn.insert_id()

                for item in parsed['items']:
                    cursor.execute("""
                        INSERT INTO invoice_items (invoice_id, item_name, quantity, unit_price, subtotal)
                        VALUES (%s, %s, %s, %s, %s)
                    """, (
                        invoice_id,
                        item['name'],
                        item['qty'],
                        item['price'],
                        item['subtotal']
                    ))
            conn.commit()
    except Exception as e:
        print(f"❌ DB 寫入失敗：{e}")
        return jsonify({'error': f'DB 儲存失敗: {str(e)}'}), 500

    print("✅ 已準備回傳前端")
    return jsonify({
        "status": "success",
        "parsed": parsed,
        "qr_raw": raw
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
