import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QualityControlPage extends StatefulWidget {
  @override
  _QualityControlPageState createState() => _QualityControlPageState();
}

class _QualityControlPageState extends State<QualityControlPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> qualityInspections = [];
  List<Map<String, dynamic>> spools = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await Future.wait([
        fetchQualityInspections(),
        fetchSpools(),
      ]);
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  Future<void> fetchQualityInspections() async {
    final result = await supabase
        .from('quality_control')
        .select('*, spools(spool_number, material), users(username)')
        .order('created_at', ascending: false);
    setState(() {
      qualityInspections = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> fetchSpools() async {
    final result = await supabase
        .from('spools')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false);
    setState(() {
      spools = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> addQualityInspection(Map<String, dynamic> spool) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => QualityInspectionDialog(
        spool: spool,
        onSave: (inspectionData) async {
          try {
            await supabase.from('quality_control').insert({
              'spool_id': spool['id'],
              'inspector_id': user.id,
              'result': inspectionData['result'],
              'notes': inspectionData['notes'],
              'defects': inspectionData['defects'],
            });
            Navigator.pop(context);
            await fetchQualityInspections();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kalite kontrol kaydı eklendi')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Hata: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'passed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getResultText(String result) {
    switch (result) {
      case 'passed':
        return 'Geçti';
      case 'failed':
        return 'Başarısız';
      case 'pending':
        return 'Beklemede';
      default:
        return 'Bilinmiyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 12);

    return Scaffold(
      appBar: AppBar(
        title: Text("Kalite Kontrol", style: TextStyle(fontSize: titleFont)),
        backgroundColor: Color(0xFF186bfd),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchData,
          ),
        ],
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
            Text(
              "Spool Kalite Kontrolü",
              style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
            Expanded(
              child: spools.isEmpty
                  ? Center(child: Text('Kontrol edilecek spool bulunmuyor', style: TextStyle(fontSize: labelFont)))
                  : ListView.builder(
                itemCount: spools.length,
                itemBuilder: (context, index) {
                  final spool = spools[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: ListTile(
                      title: Text(
                        "Spool No: ${spool['spool_number']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Malzeme: ${spool['material']} | Çap: ${spool['diameter']} | Ağırlık: ${spool['weight']}kg",
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => addQualityInspection(spool),
                        child: Text('Kontrol Et'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF186bfd),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),
            Text(
              "Kalite Kontrol Geçmişi",
              style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
            Expanded(
              child: qualityInspections.isEmpty
                  ? Center(child: Text('Henüz kalite kontrol kaydı yok', style: TextStyle(fontSize: labelFont)))
                  : ListView.builder(
                itemCount: qualityInspections.length,
                itemBuilder: (context, index) {
                  final inspection = qualityInspections[index];
                  final spool = inspection['spools'] ?? {};
                  final inspector = inspection['users'] ?? {};
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getResultColor(inspection['result']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          inspection['result'] == 'passed' ? Icons.check : Icons.close,
                          color: _getResultColor(inspection['result']),
                        ),
                      ),
                      title: Text(
                        "Spool No: ${spool['spool_number'] ?? 'N/A'}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sonuç: ${_getResultText(inspection['result'])}"),
                          Text("Kontrolör: ${inspector['username'] ?? 'N/A'}"),
                          if (inspection['notes'] != null && inspection['notes'].isNotEmpty)
                            Text("Not: ${inspection['notes']}"),
                        ],
                      ),
                      trailing: Text(
                        "${DateTime.parse(inspection['created_at']).day}/${DateTime.parse(inspection['created_at']).month}",
                        style: TextStyle(fontSize: 12),
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

class QualityInspectionDialog extends StatefulWidget {
  final Map<String, dynamic> spool;
  final Function(Map<String, dynamic>) onSave;

  QualityInspectionDialog({required this.spool, required this.onSave});

  @override
  _QualityInspectionDialogState createState() => _QualityInspectionDialogState();
}

class _QualityInspectionDialogState extends State<QualityInspectionDialog> {
  String selectedResult = 'pending';
  final TextEditingController notesController = TextEditingController();
  List<String> selectedDefects = [];

  final List<String> defectTypes = [
    'Kaynak Hatası',
    'Boyut Hatası',
    'Malzeme Hatası',
    'Yüzey Hatası',
    'Montaj Hatası',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Kalite Kontrol - ${widget.spool['spool_number']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sonuç:'),
            DropdownButton<String>(
              value: selectedResult,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'passed', child: Text('Geçti')),
                DropdownMenuItem(value: 'failed', child: Text('Başarısız')),
                DropdownMenuItem(value: 'pending', child: Text('Beklemede')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedResult = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Hata Türleri (Çoklu seçim):'),
            ...defectTypes.map((defect) => CheckboxListTile(
              title: Text(defect),
              value: selectedDefects.contains(defect),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedDefects.add(defect);
                  } else {
                    selectedDefects.remove(defect);
                  }
                });
              },
            )),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave({
              'result': selectedResult,
              'notes': notesController.text,
              'defects': selectedDefects,
            });
          },
          child: Text('Kaydet'),
        ),
      ],
    );
  }
}