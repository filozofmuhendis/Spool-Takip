import 'package:flutter/material.dart';

class RealTimeTrackingPage extends StatefulWidget {
  @override
  _RealTimeTrackingPageState createState() => _RealTimeTrackingPageState();
}

class _RealTimeTrackingPageState extends State<RealTimeTrackingPage> {
  // Listeyi filtrelemek için kullanılan text controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSpacing = screenWidth > 600 ? 20 : 10; // Responsive spacing

    final trackingSections = [
      {
        'title': 'Kesim',
        'value': 'Tamamlandı',
        'icon': Icons.cut,
        'color': Colors.green,
      },
      {
        'title': 'Dikim',
        'value': 'Devam Ediyor',
        'icon': Icons.device_hub_sharp,
        'color': Colors.orange,
      },
      {
        'title': 'Ütü & Paket',
        'value': 'Bekleniyor',
        'icon': Icons.checkroom,
        'color': Colors.redAccent,
      },
      {
        'title': 'Teslimat',
        'value': 'Hazırlanıyor',
        'icon': Icons.local_shipping,
        'color': Colors.blue,
      },
    ];

    // Arama sorgusuna göre filtrelenmiş liste
    final filteredSections = trackingSections.where((section) {
      return section['title']!
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Anlık Takip',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arama Çubuğu
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Ara',
                hintText: 'Durum arayın...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 20),
            // Bölüm Başlığı
            Text(
              "Üretim Durumu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Parti Durum Kartları
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 4 : 2, // Tablet ve telefon
                  crossAxisSpacing: cardSpacing,
                  mainAxisSpacing: cardSpacing,
                  childAspectRatio: 1.2, // Kart boyutları
                ),
                itemCount: filteredSections.length,
                itemBuilder: (context, index) {
                  final section = filteredSections[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            section['icon'] as IconData?,
                            size: 40,
                            color: section['color'] as Color,
                          ),
                          SizedBox(height: 10),
                          Text(
                            section['title'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            section['value'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              color: section['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Alt Bilgi
            Center(
              child: Text(
                "Tüm süreçler anlık olarak güncellenmektedir.",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
