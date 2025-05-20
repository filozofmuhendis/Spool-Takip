import 'package:flutter/material.dart';

class SpoolDetailPage extends StatelessWidget {
  final Map<String, dynamic> spoolData;

  SpoolDetailPage({required this.spoolData});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> history = spoolData['history'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Spool Detayı"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spool Bilgileri
            _sectionTitle("Spool Bilgileri"),
            _infoTile("Spool No", spoolData['spoolNumber']),
            _infoTile("Malzeme", spoolData['material']),
            _infoTile("Çap", spoolData['diameter']),
            _infoTile("Ağırlık", spoolData['weight']),
            _infoTile("Barkod", spoolData['barcode']),
            SizedBox(height: 16),

            // İşlem Geçmişi
            _sectionTitle("İşlem Geçmişi"),
            if (history.isEmpty)
              Text("Herhangi bir işlem kaydı yok."),
            ...history.map((entry) {
              return ListTile(
                leading: Icon(Icons.build),
                title: Text(entry['type']),
                subtitle: Text("${entry['date']} • ${entry['person']}"),
              );
            }),

            SizedBox(height: 24),

            // Belgeler / Fotoğraflar
            _sectionTitle("Fotoğraflar & Belgeler"),
            spoolData['documents'] != null
                ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(spoolData['documents'].length, (index) {
                final doc = spoolData['documents'][index];
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(doc),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
            )
                : Text("Yüklü belge bulunmamaktadır."),

            SizedBox(height: 24),

            // Proje Klasörü Bağlantısı
            _sectionTitle("Proje Klasörü"),
            TextButton.icon(
              onPressed: () {
                // TODO: Link açma işlemi
              },
              icon: Icon(Icons.folder),
              label: Text("Klasöre Git"),
            ),

            SizedBox(height: 24),

            // İş Yükü Değerlendirme (Opsiyonel)
            _sectionTitle("İş Yükü Değerlendirme (Opsiyonel)"),
            _infoTile("Ek Sayısı", spoolData['ek'] ?? "-"),
            _infoTile("Flanş Sayısı", spoolData['flans'] ?? "-"),
            _infoTile("Manşon", spoolData['manson'] ?? "-"),
            _infoTile("Kaynak Inch", spoolData['inch'] ?? "-"),
            _infoTile("Kaynak Türü", spoolData['type'] ?? "-"),
            _infoTile("Not", spoolData['note'] ?? "-"),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("$label:", style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
