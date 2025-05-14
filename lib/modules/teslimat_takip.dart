import 'package:flutter/material.dart';

class DeliveryTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSpacing = screenWidth > 600 ? 20 : 10; // Responsive spacing

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teslimat Takip',
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
              "Teslimatlar",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Teslimat Kartları
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemCount: 5, // Örnek olarak 5 teslimat
                itemBuilder: (context, index) {
                  final deliveryData = [
                    {
                      'destination': 'Merkez Depo',
                      'model': 'Model No: 51091',
                      'status': 'Yolda',
                      'progress': 70, // % Tamamlanma
                      'missing': 0,
                    },
                    {
                      'destination': 'Avcılar Şube',
                      'model': 'Model No: 6735',
                      'status': 'Eksik Teslim',
                      'progress': 80,
                      'missing': 5, // Eksik adet
                    },
                    {
                      'destination': 'Esenler Şube',
                      'model': 'Model No: 8923',
                      'status': 'Tamamlandı',
                      'progress': 100,
                      'missing': 0,
                    },
                    {
                      'destination': 'Kadıköy Şube',
                      'model': 'Model No: 45032',
                      'status': 'Hazırlanıyor',
                      'progress': 20,
                      'missing': 0,
                    },
                    {
                      'destination': 'Başakşehir Şube',
                      'model': 'Model No: 6201',
                      'status': 'Yolda',
                      'progress': 50,
                      'missing': 2,
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
                            'Teslimat Noktası: ${deliveryData[index]['destination']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            deliveryData[index]['model']! as String,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Durum: ${deliveryData[index]['status']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                            ),
                          ),
                          if ((deliveryData[index]['missing'] as int) > 0) ...[
                            SizedBox(height: 8),
                            Text(
                              'Eksik Ürün: ${deliveryData[index]['missing']} adet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                          SizedBox(height: 10),
                          // İlerleme Çubuğu
                          LinearProgressIndicator(
                            value: (deliveryData[index]['progress']! as int) / 100,
                            color: Colors.green,
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '%${deliveryData[index]['progress']} tamamlandı',
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
          // Yeni teslimat ekleme sayfasına yönlendirme
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}
