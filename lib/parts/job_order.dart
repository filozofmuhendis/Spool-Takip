import 'package:flutter/material.dart';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';


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
  int? editingIndex;

  Future<void> submitJobOrder() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    // 1. Project kaydı
    final projectInsert = await Supabase.instance.client.from('projects').insert({
      'name': _projectController.text,
      'shipyard': _shipyardController.text,
      'ship': _shipController.text,
      'created_by': userId,
    }).select().single();

    final projectId = projectInsert['id'];

    // 2. Circuit kaydı
    final circuitInsert = await Supabase.instance.client.from('circuits').insert({
      'name': _circuitController.text,
      'project_id': projectId,
      'created_by': userId,
    }).select().single();

    final circuitId = circuitInsert['id'];

    // 3. Her bir spool’u kaydet
    for (var spool in spoolList) {
      await Supabase.instance.client.from('spools').insert({
        'circuit_id': circuitId,
        'spool_number': spool['spoolNumber'],
        'diameter': spool['diameter'],
        'material': spool['material'],
        'weight': spool['weight'],
        'barcode': spool['barcode'],
        'created_by': userId,
      });
    }

    // 🟢 Kullanıcıya bildirim
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İş emri başarıyla oluşturuldu")));
      setState(() {
        _shipyardController.clear();
        _shipController.clear();
        _projectController.clear();
        _circuitController.clear();
        spoolList.clear();
      });
    }
  }


  void addSpool() {
    final spool = {
      'spoolNumber': _spoolNumberController.text,
      'diameter': _diameterController.text,
      'material': _materialController.text,
      'weight': _weightController.text,
      'barcode': "SP${Random().nextInt(99999).toString().padLeft(5, '0')}",
    };

    setState(() {
      if (editingIndex != null) {
        spool['barcode'] = spoolList[editingIndex!]['barcode']; // Barkod aynı kalmalı
        spoolList[editingIndex!] = spool;
        editingIndex = null;
      } else {
        spoolList.add(spool);
      }
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
                    ...spoolList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final spool = entry.value;

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text("Spool No: ${spool['spoolNumber']}"),
                          subtitle: Text("Çap: ${spool['diameter']} - Malzeme: ${spool['material']} - Ağırlık: ${spool['weight']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  setState(() {
                                    editingIndex = index;
                                    _spoolNumberController.text = spool['spoolNumber'];
                                    _diameterController.text = spool['diameter'];
                                    _materialController.text = spool['material'];
                                    _weightController.text = spool['weight'];
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    spoolList.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: submitJobOrder,
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
            ],
          ),
        ),
      ),
    );
  }
}
