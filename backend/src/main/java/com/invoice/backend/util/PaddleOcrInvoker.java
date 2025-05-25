// Java 程式：呼叫 PaddleOCR CLI 並取得輸出結果

package com.invoice.backend.util;

import java.io.*;

public class PaddleOcrInvoker {

    public static String runOcr(File imageFile) throws IOException, InterruptedException {
        // 1. 建立命令（路徑依實際安裝位置調整）
        String pythonExe = "python"; // 或 "python3"，依系統設定
        String scriptPath = "C:/Users/smagg/paddleocr/tools/infer/predict_system.py";
        String imagePath = imageFile.getAbsolutePath();

        ProcessBuilder pb = new ProcessBuilder(
            pythonExe,
            scriptPath,
            "--image_dir", imagePath,
            "--use_angle_cls", "true",
            "--lang", "ch"
        );

        pb.redirectErrorStream(true);
        Process process = pb.start();

        BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
        StringBuilder output = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            output.append(line).append("\n");
        }

        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("PaddleOCR failed with code " + exitCode);
        }

        return output.toString();
    }
}
