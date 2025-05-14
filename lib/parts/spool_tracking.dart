import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SpoolEntryTrackingPage extends StatefulWidget {
  @override
  _SpoolEntryTrackingPageState createState() => _SpoolEntryTrackingPageState();
}

class _SpoolEntryTrackingPageState extends State<SpoolEntryTrackingPage> {
  String? scannedCode;
  TextEditingController _spoolNameController = TextEditingController();
  TextEditingController _spoolWeightController = TextEditingController();
  String selectedStatus = 'Beklemede';
  bool isLoading = false;
  List<String> statuses = ['Beklemede', 'İşlemde', 'Tamamlandı', 'Sevkiyata Hazır'];

  void _saveSpoolEntry() {
    if (_spoolNameController.text.isEmpty || _spoolWeightController.text.isEmpty || scannedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lütfen tüm alanları doldurunuz")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        scannedCode = null;
        _spoolNameController.clear();
        _spoolWeightController.clear();
        selectedStatus = 'Beklemede';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Spool kaydı başarıyla eklendi")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spool Giriş ve Takip"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final code = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BarcodeScannerPage()),
                  );
                  if (code != null) {
                    setState(() {
                      scannedCode = code;
                    });
                  }
                },
                icon: Icon(Icons.qr_code_scanner),
                label: Text(scannedCode == null ? "Barkod Okut" : "Barkod: $scannedCode"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _spoolNameController,
                decoration: InputDecoration(
                  labelText: "Spool Adı",
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _spoolWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Spool Ağırlığı (kg)",
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField(
                value: selectedStatus,
                items: statuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value.toString();
                  });
                },
                decoration: InputDecoration(
                  labelText: "Durum",
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              SizedBox(height: 24),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveSpoolEntry,
                child: Text("Kaydet", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xFF186bfd),
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

class BarcodeScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Barkod Tarayıcı"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcodeCapture) {
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          for (final barcode in barcodes) {
            final code = barcode.rawValue;
            if (code != null) {
              print('Barkod: $code');
            }
          }
        },
      ),
    );
  }
}



class SpoolTrackingPage extends StatefulWidget {
  @override
  _SpoolTrackingPageState createState() => _SpoolTrackingPageState();
}

class _SpoolTrackingPageState extends State<SpoolTrackingPage> {
  final List<Map<String, dynamic>> materialLog = [];
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _invoiceController = TextEditingController();
  String _selectedType = 'Gelen Malzeme';
  File? _selectedImage;

  void addMaterialLog(String type) {
    if (_barcodeController.text.isNotEmpty) {
      setState(() {
        materialLog.add({
          'barcode': _barcodeController.text,
          'type': type,
          'invoice': _invoiceController.text,
          'description': _descriptionController.text,
          'date': DateTime.now().toString().split(' ')[0],
          'image': _selectedImage,
        });
        _barcodeController.clear();
        _descriptionController.clear();
        _invoiceController.clear();
        _selectedImage = null;
      });
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> scanBarcode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Barkod Tarayıcı")),
          body: MobileScanner(
            onDetect: (BarcodeCapture barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;
              for (final barcode in barcodes) {
                final code = barcode.rawValue;
                if (code != null) {
                  print('Barkod: $code');
                }
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spool Giriş ve Takip"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Malzeme Türü Seçimi
            Text(
              "Malzeme Türü",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: ['Gelen Malzeme', 'Giden Malzeme', 'Hata Bildirimi']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            SizedBox(height: 16),

            // Barkod Girişi
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: "Barkod veya Spool Numarası",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  onPressed: scanBarcode,
                  iconSize: 40,
                  color: Color(0xFF186bfd),
                ),
              ],
            ),
            SizedBox(height: 16),

            // İrsaliye ve Açıklama Girişi
            if (_selectedType != 'Hata Bildirimi')
              TextField(
                controller: _invoiceController,
                decoration: InputDecoration(
                  labelText: "İrsaliye Numarası",
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Açıklama",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Fotoğraf Ekleme
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: Icon(Icons.add_a_photo),
                  label: Text("Fotoğraf Ekle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF186bfd),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                if (_selectedImage != null)
                  Image.file(_selectedImage!, width: 80, height: 80),
              ],
            ),
            SizedBox(height: 16),

            // Kayıt Butonu
            ElevatedButton.icon(
              onPressed: () => addMaterialLog(_selectedType),
              icon: Icon(Icons.add),
              label: Text("Kayıt Ekle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF186bfd),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Kayıtlı Malzemeler
            Expanded(
              child: ListView.builder(
                itemCount: materialLog.length,
                itemBuilder: (context, index) {
                  final item = materialLog[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: item['image'] != null
                          ? Image.file(item['image'], width: 60, height: 60)
                          : Icon(Icons.image_not_supported),
                      title: Text("${item['type']} - ${item['barcode']}"),
                      subtitle: Text(
                          "${item['date']} - ${item['invoice']} - ${item['description']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            materialLog.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}