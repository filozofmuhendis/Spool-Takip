import 'package:flutter/material.dart';

class FasonTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSpacing = screenWidth > 600 ? 20 : 10; // Responsive spacing

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fason Takip',
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
              "Fason İşlemleri",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Fason İşlemleri Listesi
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemCount: 5, // Örnek olarak 5 fason süreci
                itemBuilder: (context, index) {
                  final fasonData = [
                    {
                      'atelier': 'Esenler Osman Atölyesi',
                      'model': 'Model No: 51091',
                      'status': 'Aksesuar Dikimi',
                      'progress': 70, // % Tamamlanma
                    },
                    {
                      'atelier': 'Birlik Dikim Atölyesi',
                      'model': 'Model No: 6735',
                      'status': 'Cep Dikimi',
                      'progress': 40,
                    },
                    {
                      'atelier': 'Kadıköy Fason',
                      'model': 'Model No: 8923',
                      'status': 'Birleştirme Dikimi',
                      'progress': 50,
                    },
                    {
                      'atelier': 'Başakşehir Tekstil',
                      'model': 'Model No: 45032',
                      'status': 'Bekleniyor',
                      'progress': 10,
                    },
                    {
                      'atelier': 'Avcılar Dikiş',
                      'model': 'Model No: 6201',
                      'status': 'Tamamlandı',
                      'progress': 100,
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
                            fasonData[index]['atelier']! as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            fasonData[index]['model']! as String,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Durum: ${fasonData[index]['status']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 10),
                          // İlerleme Çubuğu
                          LinearProgressIndicator(
                            value: (fasonData[index]['progress'] as int) / 100,
                            color: Colors.green,
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '%${fasonData[index]['progress']} tamamlandı',
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
          // Yeni fason işlemi ekleme sayfasına yönlendirme
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}
