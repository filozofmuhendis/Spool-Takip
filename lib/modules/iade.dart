import 'package:flutter/material.dart';

class ReturnsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSpacing = screenWidth > 600 ? 20 : 10; // Responsive spacing

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İadeler Takip',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              "İade Listesi",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // İade Kartları
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemCount: 5, // Örnek olarak 5 iade
                itemBuilder: (context, index) {
                  final returnsData = [
                    {
                      'returnId': 'RT-1001',
                      'product': 'Model No: 51091',
                      'reason': 'Kumaş Hatası',
                      'status': 'İşlemde',
                      'quantity': 20,
                      'progress': 50,
                    },
                    {
                      'returnId': 'RT-1002',
                      'product': 'Model No: 6735',
                      'reason': 'Dikiş Sorunu',
                      'status': 'Tamamlandı',
                      'quantity': 10,
                      'progress': 100,
                    },
                    {
                      'returnId': 'RT-1003',
                      'product': 'Model No: 8923',
                      'reason': 'Hatalı Renk',
                      'status': 'Bekliyor',
                      'quantity': 15,
                      'progress': 0,
                    },
                    {
                      'returnId': 'RT-1004',
                      'product': 'Model No: 45032',
                      'reason': 'Eksik Aksesuar',
                      'status': 'Planlandı',
                      'quantity': 5,
                      'progress': 20,
                    },
                    {
                      'returnId': 'RT-1005',
                      'product': 'Model No: 6201',
                      'reason': 'Müşteri Şikayeti',
                      'status': 'İşlemde',
                      'quantity': 8,
                      'progress': 40,
                    },
                  ];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'İade ID: ${returnsData[index]['returnId']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ürün: ${returnsData[index]['product']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Neden: ${returnsData[index]['reason']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Durum: ${returnsData[index]['status']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _getStatusColor(returnsData[index]['status'] as String),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Adet: ${returnsData[index]['quantity']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          // İlerleme Çubuğu
                          LinearProgressIndicator(
                            value: (returnsData[index]['progress'] as int) / 100,
                            color: Colors.green,
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '%${returnsData[index]['progress']} tamamlandı',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni iade ekleme sayfasına yönlendirme
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }

  // Durum rengine göre metin rengi belirleme fonksiyonu
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tamamlandı':
        return Colors.green;
      case 'İşlemde':
        return Colors.blue;
      case 'Bekliyor':
        return Colors.orange;
      case 'Planlandı':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
