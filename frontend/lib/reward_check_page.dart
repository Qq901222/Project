import 'package:flutter/material.dart';

class RewardCheckPage extends StatefulWidget {
  const RewardCheckPage({super.key});

  @override
  State<RewardCheckPage> createState() => _RewardCheckPageState();
}

class _RewardCheckPageState extends State<RewardCheckPage> {
  final _inputController = TextEditingController();

  //  暫時無中獎號碼，保留空清單
  final List<String> winningNumbers = [];

  String result = '';

  void checkWinning() {
    final input = _inputController.text.trim().toUpperCase();
    if (input.isEmpty) {
      setState(() {
        result = '請輸入發票號碼';
      });
      return;
    }

    if (winningNumbers.isEmpty) {
      setState(() {
        result = '目前尚未提供中獎號碼，請稍後再試';
      });
      return;
    }

    if (winningNumbers.contains(input)) {
      setState(() {
        result = '恭喜！這張發票中獎了！';
      });
    } else {
      setState(() {
        result = '很抱歉，這張發票沒有中獎。';
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('對獎查詢')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '請輸入你要查詢的發票號碼',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: '發票號碼',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('開始對獎'),
              onPressed: checkWinning,
            ),
            const SizedBox(height: 30),
            Text(
              result,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
