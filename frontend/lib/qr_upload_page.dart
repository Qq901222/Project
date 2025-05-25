import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class QrUploadPage extends StatefulWidget {
  @override
  _QrUploadPageState createState() => _QrUploadPageState();
}

class _QrUploadPageState extends State<QrUploadPage> {
  File? _image;
  String _result = '尚未上傳圖片';

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // 可改成 camera

    if (pickedFile == null) {
      print('⚠️ 沒有選到圖片');
      return;
    }

    setState(() {
      _image = File(pickedFile.path);
      _result = '上傳中...';
    });

    print('📷 圖片路徑：${_image!.path}');

    final url = Uri.parse('http://192.168.0.127:5001/qr'); // 請改成你的後端 IP

    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    print('📡 已建立 MultipartRequest');

    try {
      final response = await request.send().timeout(Duration(seconds: 10));
      final responseBody = await response.stream.bytesToString();

      print('📩 回應狀態碼：${response.statusCode}');
      print('📩 回應內容：$responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final parsed = data['parsed'];
        final header = parsed['header'];
        final items = parsed['items'];

        String itemText = '';
        for (var item in items) {
          itemText +=
              '${item['name']} x${item['qty']} 單價:${item['price']} 小計:${item['subtotal']}\n';
        }

        setState(() {
          _result = '發票號碼：$header\n\n品項：\n$itemText';
        });
      } else {
        setState(() => _result = '錯誤：${response.statusCode}');
      }
    } catch (e) {
      print('❌ 傳送錯誤：$e');
      setState(() => _result = '錯誤：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('發票上傳辨識')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, fit: BoxFit.contain)
            else
              Container(height: 200, color: Colors.grey[200]),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: Text('拍照並辨識'),
            ),
            SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
