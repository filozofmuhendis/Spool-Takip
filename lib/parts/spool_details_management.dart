import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';

class SpoolDetailsManagementPage extends StatefulWidget {
  @override
  _SpoolDetailsManagementPageState createState() => _SpoolDetailsManagementPageState();
}

class _SpoolDetailsManagementPageState extends State<SpoolDetailsManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> spools = [];
  List<Map<String, dynamic>> spoolDetails = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // Spool listesini yükle
      final spoolsResponse = await supabase
          .from('spools')
          .select()
          .order('spool_number');

      // Spool detaylarını yükle
      final detailsResponse = await supabase
          .from('spool_details')
          .select('*, spools(spool_number, title)')
          .order('created_at', ascending: false);

      setState(() {
        spools = List<Map<String, dynamic>>.from(spoolsResponse);
        spoolDetails = List<Map<String, dynamic>>.from(detailsResponse);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu: $e';
        loading = false;
      });
    }
  }

  Future<void> _showSpoolDetailsDialog([Map<String, dynamic>? detail]) async {
    final isEditing = detail != null;
    final formKey = GlobalKey<FormState>();

    final spoolNumberController = TextEditingController(text: detail?['spool_number'] ?? '');
    final materialController = TextEditingController(text: detail?['material'] ?? '');
    final diameterController = TextEditingController(text: detail?['diameter'] ?? '');
    final weightController = TextEditingController(text: detail?['weight'] ?? '');
    final barcodeController = TextEditingController(text: detail?['barcode'] ?? '');
    final ekController = TextEditingController(text: detail?['ek'] ?? '');
    final flansController = TextEditingController(text: detail?['flans'] ?? '');
    final mansonController = TextEditingController(text: detail?['manson'] ?? '');
    final inchController = TextEditingController(text: detail?['inch'] ?? '');
    final typeController = TextEditingController(text: detail?['type'] ?? '');
    final noteController = TextEditingController(text: detail?['note'] ?? '');
    final drawingNumberController = TextEditingController(text: detail?['drawing_number'] ?? '');
    final isometricNumberController = TextEditingController(text: detail?['isometric_number'] ?? '');

    int? selectedSpoolId = detail?['spool_id'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Spool Detay Düzenle' : 'Yeni Spool Detay Ekle'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedSpoolId,
                  decoration: InputDecoration(
                    labelText: 'Spool *',
                    border: OutlineInputBorder(),
                  ),
                  items: spools.map((spool) {
                    return DropdownMenuItem<int>(
                      value: spool['id'],
                      child: Text('${spool['spool_number']} - ${spool['title'] ?? ''}'),
                    );
                  }).toList(),
                  onChanged: (value) => selectedSpoolId = value,
                  validator: (value) {
                    if (value == null) {
                      return 'Spool seçimi gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: spoolNumberController,
                  decoration: InputDecoration(
                    labelText: 'Spool Numarası',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: materialController,
                        decoration: InputDecoration(
                          labelText: 'Malzeme',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: diameterController,
                        decoration: InputDecoration(
                          labelText: 'Çap',
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
                      child: TextFormField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: 'Ağırlık',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: barcodeController,
                        decoration: InputDecoration(
                          labelText: 'Barkod',
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
                      child: TextFormField(
                        controller: ekController,
                        decoration: InputDecoration(
                          labelText: 'EK',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: flansController,
                        decoration: InputDecoration(
                          labelText: 'Flans',
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
                      child: TextFormField(
                        controller: mansonController,
                        decoration: InputDecoration(
                          labelText: 'Manson',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: inchController,
                        decoration: InputDecoration(
                          labelText: 'İnç',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Tip',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: drawingNumberController,
                        decoration: InputDecoration(
                          labelText: 'Çizim No',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: isometricNumberController,
                        decoration: InputDecoration(
                          labelText: 'İzometrik No',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notlar',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final detailData = {
                    'spool_id': selectedSpoolId,
                    'spool_number': spoolNumberController.text,
                    'material': materialController.text,
                    'diameter': diameterController.text,
                    'weight': weightController.text,
                    'barcode': barcodeController.text,
                    'ek': ekController.text,
                    'flans': flansController.text,
                    'manson': mansonController.text,
                    'inch': inchController.text,
                    'type': typeController.text,
                    'note': noteController.text,
                    'drawing_number': drawingNumberController.text,
                    'isometric_number': isometricNumberController.text,
                  };

                  if (isEditing) {
                    await supabase
                        .from('spool_details')
                        .update(detailData)
                        .eq('id', detail!['id']);
                  } else {
                    await supabase
                        .from('spool_details')
                        .insert(detailData);
                  }

                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Detay güncellendi' : 'Detay eklendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Güncelle' : 'Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSpoolDetail(int detailId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Spool Detay Sil'),
        content: Text('Bu spool detayını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase
            .from('spool_details')
            .delete()
            .eq('id', detailId);

        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Spool detay silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spool Detay Yönetimi'),
        backgroundColor: Color(0xFF186bfd),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(errorMessage!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Tekrar Dene'),
            ),
          ],
        ),
      )
          : spoolDetails.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.details, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Henüz spool detay bulunmuyor'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showSpoolDetailsDialog(),
              child: Text('İlk Detay Ekle'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: spoolDetails.length,
        itemBuilder: (context, index) {
          final detail = spoolDetails[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      detail['spool_number'] ?? detail['spools']['spool_number'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (detail['barcode'] != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Barkod',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  if (detail['spools'] != null)
                    Text('Spool: ${detail['spools']['spool_number']}'),
                  if (detail['material'] != null)
                    Text('Malzeme: ${detail['material']}'),
                  if (detail['diameter'] != null)
                    Text('Çap: ${detail['diameter']}'),
                  if (detail['weight'] != null)
                    Text('Ağırlık: ${detail['weight']}'),
                  if (detail['ek'] != null)
                    Text('EK: ${detail['ek']}'),
                  if (detail['flans'] != null)
                    Text('Flans: ${detail['flans']}'),
                  if (detail['manson'] != null)
                    Text('Manson: ${detail['manson']}'),
                  if (detail['inch'] != null)
                    Text('İnç: ${detail['inch']}'),
                  if (detail['type'] != null)
                    Text('Tip: ${detail['type']}'),
                  if (detail['drawing_number'] != null)
                    Text('Çizim No: ${detail['drawing_number']}'),
                  if (detail['isometric_number'] != null)
                    Text('İzometrik No: ${detail['isometric_number']}'),
                  if (detail['note'] != null)
                    Text('Not: ${detail['note']}'),
                  SizedBox(height: 8),
                  Text(
                    'Oluşturulma: ${DateTime.parse(detail['created_at']).toString().substring(0, 16)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showSpoolDetailsDialog(detail);
                  } else if (value == 'delete') {
                    _deleteSpoolDetail(detail['id']);
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSpoolDetailsDialog(),
        backgroundColor: Color(0xFF186bfd),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}