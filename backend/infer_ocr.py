from paddleocr import PaddleOCR, draw_ocr
from PIL import Image
import matplotlib.pyplot as plt

# 初始化 OCR 模型（中文、關閉方向分類）
ocr = PaddleOCR(use_angle_cls=False, lang='ch')  

# 讀取圖片
image_path = 'example.jpg'
result = ocr.ocr(image_path, cls=False)

# 顯示文字結果
for line in result:
    for box, (text, score) in zip(line[0], line[1]):
        print(f"{text} (信心度: {score:.2f})")

# 畫出文字與框線
image = Image.open(image_path).convert('RGB')
boxes = [elements[0] for elements in result[0]]
txts = [elements[1][0] for elements in result[0]]
scores = [elements[1][1] for elements in result[0]]

# 使用 draw_ocr 畫出框與文字
image_with_boxes = draw_ocr(image, boxes, txts, scores, font_path='C:/Windows/Fonts/simfang.ttf')

# 存成 result.jpg
image_with_boxes = Image.fromarray(image_with_boxes)
image_with_boxes.save('result.jpg')
