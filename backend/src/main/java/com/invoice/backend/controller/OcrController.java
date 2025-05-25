// Java Spring Boot 後端服務：呼叫 Python OCR 程式

package com.invoice.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.*;

@RestController
@RequestMapping("/api/ocr")
public class OcrController {

    @PostMapping("/upload")
    public ResponseEntity<String> uploadImageAndRecognize(@RequestParam("file") MultipartFile file) {
        try {
            // 儲存上傳檔案
            Path imagePath = Paths.get("uploads", file.getOriginalFilename());
            Files.createDirectories(imagePath.getParent());
            Files.write(imagePath, file.getBytes());

            // 呼叫 Python 腳本
            ProcessBuilder pb = new ProcessBuilder(
                "python", "infer_ocr.py", imagePath.toString()
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
                return ResponseEntity.status(500).body("OCR failed: " + output);
            }

            return ResponseEntity.ok(output.toString());

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
}

