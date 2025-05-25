import 'package:flutter/material.dart';

class SearchInvoicePage extends StatefulWidget {
  const SearchInvoicePage({super.key});

  @override
  State<SearchInvoicePage> createState() => _SearchInvoicePageState();
}

class _SearchInvoicePageState extends State<SearchInvoicePage> {
  final _keywordController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _performSearch() {
    final dummyInvoices = [
      {
        'number': 'AB12345678',
        'amount': 200,
        'item': '咖啡',
        'date': DateTime(2025, 5, 10),
      },
      {
        'number': 'CD87654321',
        'amount': 1200,
        'item': '餐廳',
        'date': DateTime(2025, 4, 20),
      },
    ];

    final keyword = _keywordController.text;
    final min = int.tryParse(_minController.text) ?? 0;
    final max = int.tryParse(_maxController.text) ?? 999999;
    final start = _startDate ?? DateTime(2000);
    final end = _endDate ?? DateTime(2100);

    final results = dummyInvoices.where((inv) {
      final amt = inv['amount'] as int;
      final date = inv['date'] as DateTime;
      return amt >= min &&
          amt <= max &&
          date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1))) &&
          inv['item'].toString().contains(keyword);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('查詢發票')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: '關鍵字（品項／店名）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '最小金額',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '最大金額',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                      _startDate != null
                          ? "起：${_startDate!.toLocal().toString().split(' ')[0]}"
                          : "選擇起始日期",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(
                      _endDate != null
                          ? "訖：${_endDate!.toLocal().toString().split(' ')[0]}"
                          : "選擇結束日期",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('查詢'),
            ),
            const SizedBox(height: 24),
            const Text('查詢結果：', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._searchResults.map((inv) => ListTile(
                  title: Text("${inv['item']} - \$${inv['amount']}"),
                  subtitle: Text("號碼: ${inv['number']} / 日期: ${inv['date'].toLocal().toString().split(' ')[0]}"),
                )),
          ],
        ),
      ),
    );
  }
}
