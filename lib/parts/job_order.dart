import 'package:flutter/material.dart';
import 'dart:math';

class JobOrderPage extends StatefulWidget {
  @override
  _JobOrderPageState createState() => _JobOrderPageState();
}

class _JobOrderPageState extends State<JobOrderPage> {
  final TextEditingController _shipyardController = TextEditingController();
  final TextEditingController _shipController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _circuitController = TextEditingController();
  final TextEditingController _spoolNumberController = TextEditingController();
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final List<Map<String, dynamic>> spoolList = [];

  void addSpool() {
    setState(() {
      final spoolNumber = _spoolNumberController.text;
      final diameter = _diameterController.text;
      final material = _materialController.text;
      final weight = _weightController.text;
      final barcode = "SP${Random().nextInt(99999).toString().padLeft(5, '0')}";

      spoolList.add({
        'spoolNumber': spoolNumber,
        'diameter': diameter,
        'material': material,
        'weight': weight,
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
        title: Text("İş Emri Oluştur"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Proje Bilgileri
              Text("Proje Bilgileri", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _shipyardController,
                decoration: InputDecoration(
                  labelText: "Tersane Adı",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _shipController,
                decoration: InputDecoration(
                  labelText: "Gemi Adı",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _projectController,
                decoration: InputDecoration(
                  labelText: "Proje Adı veya Numarası",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _circuitController,
                decoration: InputDecoration(
                  labelText: "Devre Adı",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              // Spool Listesi
              Text("Spool Listesi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _spoolNumberController,
                      decoration: InputDecoration(
                        labelText: "Spool Numarası",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _diameterController,
                      decoration: InputDecoration(
                        labelText: "Çap",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _materialController,
                      decoration: InputDecoration(
                        labelText: "Malzeme",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: "Ağırlık",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: addSpool,
                icon: Icon(Icons.add),
                label: Text("Spool Ekle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Spool Listesi Gösterimi
              if (spoolList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Spool Listesi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...spoolList.map((spool) {
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text("Spool No: ${spool['spoolNumber']}"),
                          subtitle: Text(
                              "Çap: ${spool['diameter']} - Malzeme: ${spool['material']} - Ağırlık: ${spool['weight']}"),
                          trailing: Text("Barkod: ${spool['barcode']}"),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: addSpool,
                icon: Icon(Icons.add),
                label: Text("İş Emrini Oluştur"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Barkod Yazdırma Butonu
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.print),
                label: Text("Barkodları Yazdır"),
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
      ),
    );
  }
}