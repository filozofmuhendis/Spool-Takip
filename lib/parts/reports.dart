import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spool/parts/responsive_helper.dart';

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
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 24);
    double sectionFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonPadding = ResponsiveHelper.getResponsiveHeight(context, 16);
    double chartAspect = MediaQuery.of(context).size.width > 600 ? 2.2 : 1.6;
    double pieAspect = MediaQuery.of(context).size.width > 600 ? 1.8 : 1.3;

    return Scaffold(
      appBar: AppBar(
        title: Text("Raporlar ve Performanslar", style: TextStyle(fontSize: sectionFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Üretim Performansı",
                style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
              AspectRatio(
                aspectRatio: chartAspect,
                child: BarChart(
                  BarChartData(
                    barGroups: _createBarData(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final style = TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12));
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
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 32)),
              Text(
                "Tamamlanma Oranı",
                style: TextStyle(fontSize: sectionFont, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
              AspectRatio(
                aspectRatio: pieAspect,
                child: PieChart(
                  PieChartData(
                    sections: _createPieData(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 4,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 32)),
              ElevatedButton(
                onPressed: () {},
                child: Text("PDF Olarak İndir", style: TextStyle(fontSize: buttonFont)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
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