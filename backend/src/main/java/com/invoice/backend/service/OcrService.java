package com.invoice.backend.service;

import com.invoice.backend.util.ImagePreprocessor;
import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.springframework.stereotype.Service;

import java.io.File;

@Service
public class OcrService {

    public String extractText(File imageFile) {
        try {
            // 圖像預處理（包含 deskew、去噪、放大）
            File preprocessed = ImagePreprocessor.preprocess(imageFile);

            // OCR 初始化
            Tesseract tesseract = new Tesseract();
            tesseract.setDatapath("C:/Program Files/Tesseract-OCR/tessdata");
            tesseract.setLanguage("chi_tra+eng");
            tesseract.setTessVariable("tessedit_char_whitelist", "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.-年月日:店序機 ");

            return tesseract.doOCR(preprocessed);
        } catch (TesseractException e) {
            return "OCR失敗: " + e.getMessage();
        } catch (Exception e) {
            return "預處理失敗: " + e.getMessage();
        }
    }
}

