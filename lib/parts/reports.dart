import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPerformancePage extends StatefulWidget {
  @override
  _ReportsPerformancePageState createState() => _ReportsPerformancePageState();
}

class _ReportsPerformancePageState extends State<ReportsPerformancePage> {
  final List<Map<String, dynamic>> performanceData = [
    {'name': 'Galata Tersanesi', 'completed': 50, 'inProgress': 30, 'pending': 20},
    {'name': 'Haliç Tersanesi', 'completed': 70, 'inProgress': 20, 'pending': 10},
    {'name': 'Yalova Tersanesi', 'completed': 40, 'inProgress': 40, 'pending': 20},
    {'name': 'Sedef Tersanesi', 'completed': 90, 'inProgress': 5, 'pending': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Raporlar ve Performanslar"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Üretim Performansı",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.6,
                child: BarChart(
                  BarChartData(
                    barGroups: _createBarData(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(fontWeight: FontWeight.bold);
                            switch (value.toInt()) {
                              case 0:
                                return Text('Galata', style: style);
                              case 1:
                                return Text('Haliç', style: style);
                              case 2:
                                return Text('Yalova', style: style);
                              case 3:
                                return Text('Sedef', style: style);
                            }
                            return Text('');
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                "Tamamlanma Oranı",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: _createPieData(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 4,
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                child: Text("PDF Olarak İndir"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarData() {
    return List.generate(performanceData.length, (index) {
      final data = performanceData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: data['completed'].toDouble(), color: Colors.blue, width: 16),
          BarChartRodData(toY: data['inProgress'].toDouble(), color: Colors.yellow, width: 16),
          BarChartRodData(toY: data['pending'].toDouble(), color: Colors.red, width: 16),
        ],
      );
    });
  }

  List<PieChartSectionData> _createPieData() {
    final completed = performanceData.fold<int>(0, (sum, item) => sum + (item['completed'] as int));
    final inProgress = performanceData.fold<int>(0, (sum, item) => sum + (item['inProgress'] as int));
    final pending = performanceData.fold<int>(0, (sum, item) => sum + (item['pending'] as int));

    final total = completed + inProgress + pending;
    return [
      PieChartSectionData(value: completed.toDouble(), title: 'Tamamlandı', color: Colors.blue, radius: 50),
      PieChartSectionData(value: inProgress.toDouble(), title: 'İşlemde', color: Colors.yellow, radius: 50),
      PieChartSectionData(value: pending.toDouble(), title: 'Beklemede', color: Colors.red, radius: 50),
    ];
  }
}