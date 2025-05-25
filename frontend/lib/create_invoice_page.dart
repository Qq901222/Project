import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  final _formKey = GlobalKey<FormState>();

  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _itemController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    _itemController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('建立發票'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: '發票號碼',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '金額',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: '品項',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '購買日期',
                  border: OutlineInputBorder(),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    final file = result.files.first;
                    debugPrint('選取的檔案路徑：${file.path}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已選取 QR Code 圖片')),
                    );
                  }
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('上傳 QR Code'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已儲存發票')),
                    );
                    _numberController.clear();
                    _amountController.clear();
                    _itemController.clear();
                    _dateController.clear();
                    setState(() {
                      _selectedDate = null;
                    });
                  }
                },
                child: const Text('儲存發票'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
