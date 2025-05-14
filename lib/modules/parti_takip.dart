import 'package:flutter/material.dart';

class PartyTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSpacing = screenWidth > 600 ? 20 : 10; // Responsive spacing

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parti Takip',
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
              "Parti Detayları",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Parti Kartları
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemCount: 5, // Örnek olarak 5 parti
                itemBuilder: (context, index) {
                  final partyData = [
                    {
                      'model': 'Model No: 51091',
                      'fason': 'Esenler Atölyesi',
                      'status': 'Dikim Tamamlandı',
                      'progress': 100,
                      'note': 'Ütü paketleme bekleniyor.'
                    },
                    {
                      'model': 'Model No: 6735',
                      'fason': 'Kadıköy Atölyesi',
                      'status': 'Dikim Devam Ediyor',
                      'progress': 60,
                      'note': 'Aksesuar eksikliği gideriliyor.'
                    },
                    {
                      'model': 'Model No: 8923',
                      'fason': 'Başakşehir Tekstil',
                      'status': 'Kesim Tamamlandı',
                      'progress': 40,
                      'note': 'Dikime hazır.'
                    },
                    {
                      'model': 'Model No: 45032',
                      'fason': 'Avcılar Şube',
                      'status': 'Üretim Bekleniyor',
                      'progress': 0,
                      'note': 'Malzeme bekleniyor.'
                    },
                    {
                      'model': 'Model No: 6201',
                      'fason': 'Birlik Atölyesi',
                      'status': 'Ütü Tamamlandı',
                      'progress': 100,
                      'note': 'Teslimata hazır.'
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
                            partyData[index]['model'] as String ,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Fason: ${partyData[index]['fason']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Durum: ${partyData[index]['status']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Not: ${partyData[index]['note']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          // İlerleme Çubuğu
                          LinearProgressIndicator(
                            value: (partyData[index]['progress'] as int) / 100,
                            color: Colors.green,
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '%${partyData[index]['progress']} tamamlandı',
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
          // Yeni parti ekleme sayfasına yönlendirme
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}
