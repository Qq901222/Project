import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('統計報表'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '本月花費總額',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            const Text('分類分析', style: TextStyle(fontSize: 18)),
            const Text('飲食'),
            const Text('交通'),
            const Text('購物'),
            const Text('玩樂'),
            const SizedBox(height: 16),
            const Text('分類圓餅圖', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                    sections: [
                      PieChartSectionData(
                        value: 1,
                        color: Colors.redAccent,
                        title: '飲食',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 1,
                        color: Colors.blueAccent,
                        title: '交通',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 1,
                        color: Colors.greenAccent,
                        title: '購物',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 1,
                        color: Colors.purpleAccent,
                        title: '玩樂',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('匯出報表'),
            ),
          ],
        ),
      ),
    );
  }
}
