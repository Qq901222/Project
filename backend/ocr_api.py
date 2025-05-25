from flask import Flask, request, jsonify
from paddleocr import PaddleOCR
import cv2
import numpy as np

app = Flask(__name__)

ocr = PaddleOCR(use_angle_cls=False, lang='ch')  # 初始化 OCR

@app.route('/ocr', methods=['POST'])
def detect_text():
    if 'image' not in request.files:
        return jsonify({'error': '請提供 image 檔案'}), 400
    
    file = request.files['image']
    img_bytes = file.read()
    np_arr = np.frombuffer(img_bytes, np.uint8)
    image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    result = ocr.ocr(image, cls=False)  # 直接傳入 image 而不是 img_path

    texts = []
    for line in result[0]:  # result 是 list of one image 的結果
        box, (text, score) = line
        texts.append({'text': text, 'score': score})

    return jsonify({'results': texts})

if __name__ == '__main__':
    app.run(debug=True, port=5000)

