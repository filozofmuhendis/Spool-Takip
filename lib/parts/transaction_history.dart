import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = [
    {'spoolName': 'Spool A', 'date': '08/05/2025', 'status': 'Tamamlandı', 'weight': 120},
    {'spoolName': 'Spool B', 'date': '07/05/2025', 'status': 'İşlemde', 'weight': 150},
    {'spoolName': 'Spool C', 'date': '06/05/2025', 'status': 'Sevkiyata Hazır', 'weight': 200},
    {'spoolName': 'Spool D', 'date': '05/05/2025', 'status': 'Beklemede', 'weight': 100},
    {'spoolName': 'Spool E', 'date': '04/05/2025', 'status': 'Tamamlandı', 'weight': 180},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("İşlem Geçmişi"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(transaction['spoolName'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text("Tarih: ${transaction['date']}\nDurum: ${transaction['status']}\nAğırlık: ${transaction['weight']} kg"),
                trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF186bfd)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailsPage(transaction: transaction),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  TransactionDetailsPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transaction['spoolName']),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("İşlem Detayları", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Spool Adı: ${transaction['spoolName']}"),
            Text("Durum: ${transaction['status']}"),
            Text("Tarih: ${transaction['date']}"),
            Text("Ağırlık: ${transaction['weight']} kg"),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: Text("Daha Fazla Detay"),
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
    );
  }
}