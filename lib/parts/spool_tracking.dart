import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 15);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonPadding = ResponsiveHelper.getResponsiveHeight(context, 16);
    double iconSize = ResponsiveHelper.getResponsiveWidth(context, 24);

    return Scaffold(
      appBar: AppBar(
        title: Text("Spool Giriş ve Takip", style: TextStyle(fontSize: labelFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
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
                icon: Icon(Icons.qr_code_scanner, size: iconSize),
                label: Text(scannedCode == null ? "Barkod Okut" : "Barkod: $scannedCode", style: TextStyle(fontSize: buttonFont)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardRadius),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
              TextField(
                controller: _spoolNameController,
                style: TextStyle(fontSize: labelFont),
                decoration: InputDecoration(
                  labelText: "Spool Adı",
                  prefixIcon: Icon(Icons.edit, size: iconSize),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
              TextField(
                controller: _spoolWeightController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: labelFont),
                decoration: InputDecoration(
                  labelText: "Spool Ağırlığı (kg)",
                  prefixIcon: Icon(Icons.scale, size: iconSize),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
              DropdownButtonFormField(
                value: selectedStatus,
                items: statuses.map((status) => DropdownMenuItem(value: status, child: Text(status, style: TextStyle(fontSize: labelFont)))).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value.toString();
                  });
                },
                decoration: InputDecoration(
                  labelText: "Durum",
                  prefixIcon: Icon(Icons.info_outline, size: iconSize),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveSpoolEntry,
                child: Text("Kaydet", style: TextStyle(fontSize: buttonFont)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  backgroundColor: Color(0xFF186bfd),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardRadius),
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

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Barkod Tarayıcı"),
        backgroundColor: Color(0xFF186bfd),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                final List<Barcode> barcodes = barcodeCapture.barcodes;
                for (final barcode in barcodes) {
                  final code = barcode.rawValue;
                  if (code != null) {
                    setState(() {
                      scannedCode = code;
                    });
                    // Tarama sonucunu geri döndür
                    Navigator.pop(context, code);
                    return;
                  }
                }
              },
            ),
          ),
          if (scannedCode != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Barkod okundu: $scannedCode',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SpoolTrackingPage extends StatefulWidget {
  @override
  _SpoolTrackingPageState createState() => _SpoolTrackingPageState();
}

class _SpoolTrackingPageState extends State<SpoolTrackingPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _invoiceController = TextEditingController();
  String _selectedType = 'Gelen Malzeme';
  File? _selectedImage;
  List<Map<String, dynamic>> materialLog = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchMaterialLog();
  }

  Future<void> fetchMaterialLog() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Kullanıcı oturumu bulunamadı.';
          loading = false;
        });
        return;
      }
      final result = await supabase
          .from('spool_material_log')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      setState(() {
        materialLog = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Kayıtlar yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  Future<void> addMaterialLog(String type) async {
    if (_barcodeController.text.isEmpty) return;
    setState(() => loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final newLog = {
        'barcode': _barcodeController.text,
        'type': type,
        'invoice': _invoiceController.text,
        'description': _descriptionController.text,
        'date': DateTime.now().toIso8601String(),
        'user_id': user.id,
        // 'image': _selectedImage, // Görseli Supabase Storage'a yüklemek için ek kod gerekir
      };
      await supabase.from('spool_material_log').insert(newLog);
      _barcodeController.clear();
      _descriptionController.clear();
      _invoiceController.clear();
      _selectedImage = null;
      await fetchMaterialLog();
    } catch (e) {
      setState(() {
        errorMessage = 'Kayıt eklenirken hata oluştu:\n${e.toString()}';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteMaterialLog(int id) async {
    setState(() => loading = true);
    try {
      await supabase.from('spool_material_log').delete().eq('id', id);
      await fetchMaterialLog();
    } catch (e) {
      setState(() {
        errorMessage = 'Kayıt silinirken hata oluştu:\n${e.toString()}';
      });
    } finally {
      setState(() => loading = false);
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerPage(),
      ),
    );
    if (result != null) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 15);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonPadding = ResponsiveHelper.getResponsiveHeight(context, 16);
    double iconSize = ResponsiveHelper.getResponsiveWidth(context, 24);

    return Scaffold(
      appBar: AppBar(
        title: Text("Spool Giriş ve Takip", style: TextStyle(fontSize: labelFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: labelFont)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Malzeme Türü Seçimi
                      Text(
                        "Malzeme Türü",
                        style: TextStyle(fontSize: labelFont, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedType,
                        isExpanded: true,
                        items: ['Gelen Malzeme', 'Giden Malzeme', 'Hata Bildirimi']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type, style: TextStyle(fontSize: labelFont)),
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
                        child: RefreshIndicator(
                          onRefresh: fetchMaterialLog,
                          child: ListView.builder(
                            itemCount: materialLog.length,
                            itemBuilder: (context, index) {
                              final item = materialLog[index];
                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  leading: Icon(Icons.inventory),
                                  title: Text("${item['type']} - ${item['barcode']}", style: TextStyle(fontSize: labelFont)),
                                  subtitle: Text(
                                    "${item['date']?.toString().substring(0, 10) ?? '-'} - ${item['invoice'] ?? ''} - ${item['description'] ?? ''}",
                                    style: TextStyle(fontSize: labelFont),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      if (item['id'] != null) {
                                        deleteMaterialLog(item['id']);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}