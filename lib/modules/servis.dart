import 'package:flutter/material.dart';

class ServiceTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSpacing = screenWidth > 600 ? 20 : 10; // Responsive spacing

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Servis Takip',
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
              "Servis Talepleri",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Servis Kartları
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemCount: 5, // Örnek olarak 5 servis talebi
                itemBuilder: (context, index) {
                  final serviceData = [
                    {
                      'serviceId': 'ST-1001',
                      'machine': 'Kesim Makinesi',
                      'assignedTo': 'Ali Yılmaz',
                      'status': 'Devam Ediyor',
                      'priority': 'Yüksek',
                      'progress': 60,
                    },
                    {
                      'serviceId': 'ST-1002',
                      'machine': 'Dikim Makinesi',
                      'assignedTo': 'Mehmet Kara',
                      'status': 'Tamamlandı',
                      'priority': 'Orta',
                      'progress': 100,
                    },
                    {
                      'serviceId': 'ST-1003',
                      'machine': 'Ütü Makinesi',
                      'assignedTo': 'Fatma Ak',
                      'status': 'Bekliyor',
                      'priority': 'Düşük',
                      'progress': 0,
                    },
                    {
                      'serviceId': 'ST-1004',
                      'machine': 'Paketleme Makinesi',
                      'assignedTo': 'Zeynep Çelik',
                      'status': 'Planlandı',
                      'priority': 'Orta',
                      'progress': 20,
                    },
                    {
                      'serviceId': 'ST-1005',
                      'machine': 'Lazer Kesim',
                      'assignedTo': 'Ahmet Demir',
                      'status': 'Gecikti',
                      'priority': 'Yüksek',
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
                            'Servis ID: ${serviceData[index]['serviceId']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Makine: ${serviceData[index]['machine']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Atanan Kişi: ${serviceData[index]['assignedTo']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Durum: ${serviceData[index]['status']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _getStatusColor(serviceData[index]['status'] as String),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Öncelik: ${serviceData[index]['priority']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _getPriorityColor(serviceData[index]['priority'] as String),
                            ),
                          ),
                          SizedBox(height: 10),
                          // İlerleme Çubuğu
                          LinearProgressIndicator(
                            value: (serviceData[index]['progress'] as int) / 100,
                            color: Colors.green,
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '%${serviceData[index]['progress']} tamamlandı',
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
          // Yeni servis talebi ekleme sayfasına yönlendirme
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
      case 'Devam Ediyor':
        return Colors.blue;
      case 'Bekliyor':
        return Colors.orange;
      case 'Planlandı':
        return Colors.grey;
      case 'Gecikti':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Öncelik rengine göre metin rengi belirleme fonksiyonu
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Yüksek':
        return Colors.redAccent;
      case 'Orta':
        return Colors.blueAccent;
      case 'Düşük':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
