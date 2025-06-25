import 'package:flutter/material.dart';

class SpoolJobOrderPage extends StatefulWidget {
  @override
  _SpoolJobOrderPageState createState() => _SpoolJobOrderPageState();
}

class _SpoolJobOrderPageState extends State<SpoolJobOrderPage> {
  final TextEditingController _circuitController = TextEditingController();
  final TextEditingController _spoolNumberController = TextEditingController();
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final List<Map<String, String>> spoolList = [];

  int barcodeCounter = 1;

  void addSpool() {
    if (_spoolNumberController.text.isEmpty ||
        _diameterController.text.isEmpty ||
        _materialController.text.isEmpty ||
        _weightController.text.isEmpty) return;

    final barcode = "SP${barcodeCounter.toString().padLeft(5, '0')}";
    barcodeCounter++;

    setState(() {
      spoolList.add({
        'spoolNumber': _spoolNumberController.text,
        'diameter': _diameterController.text,
        'material': _materialController.text,
        'weight': _weightController.text,
        'barcode': barcode,
      });

      _spoolNumberController.clear();
      _diameterController.clear();
      _materialController.clear();
      _weightController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spool İş Emri Oluştur"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Devre Adı", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              TextField(
                controller: _circuitController,
                decoration: InputDecoration(
                  hintText: "Örn: Yakıt Hattı",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              Text("Spool Bilgileri", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _spoolNumberController,
                decoration: InputDecoration(
                  labelText: "Spool No",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _diameterController,
                      decoration: InputDecoration(
                        labelText: "Çap",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _materialController,
                      decoration: InputDecoration(
                        labelText: "Malzeme",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: "Ağırlık (kg)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: addSpool,
                icon: Icon(Icons.add),
                label: Text("Spool Ekle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              SizedBox(height: 24),
              Text("Eklenen Spool Listesi", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: spoolList.length,
                itemBuilder: (context, index) {
                  final item = spoolList[index];
                  return Card(
                    child: ListTile(
                      title: Text("Spool No: ${item['spoolNumber']} • Barkod: ${item['barcode']}"),
                      subtitle: Text("Çap: ${item['diameter']} | Malzeme: ${item['material']} | Ağırlık: ${item['weight']}kg"),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Barkod yazdırma entegrasyonu buraya gelecek
                },
                icon: Icon(Icons.print),
                label: Text("Tüm Barkodları Yazdır"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
