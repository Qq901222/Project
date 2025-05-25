package com.invoice.backend.util;

import org.bytedeco.javacpp.Loader;
import org.bytedeco.opencv.global.opencv_core;
import org.bytedeco.opencv.global.opencv_imgcodecs;
import org.bytedeco.opencv.global.opencv_imgproc;
import org.bytedeco.opencv.global.opencv_photo;
import org.bytedeco.opencv.opencv_core.Mat;
import org.bytedeco.opencv.opencv_core.Rect;
import org.bytedeco.opencv.opencv_core.Size;
import org.bytedeco.opencv.opencv_core.Point;
import org.bytedeco.opencv.opencv_core.Scalar;

import java.io.File;

public class ImagePreprocessor {

    static {
        Loader.load(opencv_core.class);
    }

    public static File preprocess(File inputFile) throws Exception {
        // 讀取原始圖
        Mat src = opencv_imgcodecs.imread(inputFile.getAbsolutePath());

        // 縮放統一尺寸 (若圖太小，放大處理比較準)
        double scale = 2.0;
        Size newSize = new Size((int)(src.cols() * scale), (int)(src.rows() * scale));
        Mat resized = new Mat();
        opencv_imgproc.resize(src, resized, newSize);

        // 灰階
        Mat gray = new Mat();
        opencv_imgproc.cvtColor(resized, gray, opencv_imgproc.COLOR_BGR2GRAY);

        // 二值化（增加對比）
        Mat binary = new Mat();
        opencv_imgproc.adaptiveThreshold(gray, binary, 255,
                opencv_imgproc.ADAPTIVE_THRESH_GAUSSIAN_C,
                opencv_imgproc.THRESH_BINARY, 15, 15);

        // 形態學操作：閉運算，連接破碎文字
        Mat morph = new Mat();
        Mat kernel = opencv_imgproc.getStructuringElement(opencv_imgproc.MORPH_RECT, new Size(3, 3));
        opencv_imgproc.morphologyEx(binary, morph, opencv_imgproc.MORPH_CLOSE, kernel);

        // 邊緣偵測（可選）
        Mat edges = new Mat();
        opencv_imgproc.Canny(morph, edges, 100, 200);

        // 找輪廓並裁切最大面積區域
        Mat contours = new Mat();
        resized.copyTo(contours);
        Rect cropRect = new Rect(0, 0, resized.cols(), resized.rows()); // fallback

        var contourList = new org.bytedeco.opencv.opencv_core.MatVector();
        var hierarchy = new Mat();
        opencv_imgproc.findContours(edges, contourList, hierarchy,
                opencv_imgproc.RETR_EXTERNAL, opencv_imgproc.CHAIN_APPROX_SIMPLE);

        double maxArea = 0;
        for (int i = 0; i < contourList.size(); i++) {
            Rect rect = opencv_imgproc.boundingRect(contourList.get(i));
            double area = rect.width() * rect.height();
            if (area > maxArea) {
                maxArea = area;
                cropRect = rect;
            }
        }

        Mat cropped = new Mat(resized, cropRect);

        // 最後再灰階 + 二值化一次
        Mat finalGray = new Mat();
        opencv_imgproc.cvtColor(cropped, finalGray, opencv_imgproc.COLOR_BGR2GRAY);
        Mat finalBinary = new Mat();
        opencv_imgproc.adaptiveThreshold(finalGray, finalBinary, 255,
                opencv_imgproc.ADAPTIVE_THRESH_GAUSSIAN_C,
                opencv_imgproc.THRESH_BINARY, 11, 10);

        // 儲存為暫存檔案
        File output = new File("preprocessed_" + System.currentTimeMillis() + ".png");
        opencv_imgcodecs.imwrite(output.getAbsolutePath(), finalBinary);
        return output;
    }
}
