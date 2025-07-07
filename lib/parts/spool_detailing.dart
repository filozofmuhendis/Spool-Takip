import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpoolDetailPage extends StatefulWidget {
  final Map<String, dynamic> spoolData;

  SpoolDetailPage({required this.spoolData});

  @override
  _SpoolDetailPageState createState() => _SpoolDetailPageState();
}

class _SpoolDetailPageState extends State<SpoolDetailPage> {
  List<Map<String, dynamic>> history = [];
  List<dynamic> documents = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSpoolDetails();
  }

  Future<void> fetchSpoolDetails() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final result = await Supabase.instance.client
          .from('spool_history')
          .select()
          .eq('spool_number', widget.spoolData['spoolNumber'] ?? widget.spoolData['spool_number']);
      final docResult = await Supabase.instance.client
          .from('spool_documents')
          .select()
          .eq('spool_number', widget.spoolData['spoolNumber'] ?? widget.spoolData['spool_number']);
      setState(() {
        history = List<Map<String, dynamic>>.from(result);
        documents = docResult;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Spool detayları yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double sectionFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double iconSize = ResponsiveHelper.getResponsiveWidth(context, 24);

    final spool = widget.spoolData;

    return Scaffold(
      appBar: AppBar(
        title: Text("Spool Detayı", style: TextStyle(fontSize: sectionFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: labelFont)))
              : RefreshIndicator(
                  onRefresh: fetchSpoolDetails,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("Spool Bilgileri", sectionFont),
                        _infoTile("Spool No", spool['spoolNumber'] ?? spool['spool_number'] ?? "-", labelFont),
                        _infoTile("Malzeme", spool['material'] ?? "-", labelFont),
                        _infoTile("Çap", spool['diameter'] ?? "-", labelFont),
                        _infoTile("Ağırlık", spool['weight'] ?? "-", labelFont),
                        _infoTile("Barkod", spool['barcode'] ?? "-", labelFont),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                        _sectionTitle("İşlem Geçmişi", sectionFont),
                        if (history.isEmpty)
                          Text("Herhangi bir işlem kaydı yok.", style: TextStyle(fontSize: labelFont)),
                        ...history.map((entry) {
                          return ListTile(
                            leading: Icon(Icons.build, size: iconSize),
                            title: Text(entry['type'] ?? '-', style: TextStyle(fontSize: labelFont)),
                            subtitle: Text("${entry['date']?.toString().substring(0, 10) ?? '-'} • ${entry['person'] ?? '-'}", style: TextStyle(fontSize: labelFont)),
                          );
                        }),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),
                        _sectionTitle("Fotoğraflar & Belgeler", sectionFont),
                        documents.isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(documents.length, (index) {
                                  final doc = documents[index];
                                  return Container(
                                    width: ResponsiveHelper.getResponsiveWidth(context, 100),
                                    height: ResponsiveHelper.getResponsiveWidth(context, 100),
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(8),
                                      image: doc['url'] != null
                                          ? DecorationImage(
                                              image: NetworkImage(doc['url']),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: doc['url'] == null
                                        ? Center(child: Icon(Icons.insert_drive_file, size: iconSize))
                                        : null,
                                  );
                                }),
                              )
                            : Text("Yüklü belge bulunmamaktadır.", style: TextStyle(fontSize: labelFont)),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),
                        _sectionTitle("Proje Klasörü", sectionFont),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.folder, size: iconSize),
                          label: Text("Klasöre Git", style: TextStyle(fontSize: labelFont)),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),
                        _sectionTitle("İş Yükü Değerlendirme (Opsiyonel)", sectionFont),
                        _infoTile("Ek Sayısı", spool['ek'] ?? "-", labelFont),
                        _infoTile("Flanş Sayısı", spool['flans'] ?? "-", labelFont),
                        _infoTile("Manşon", spool['manson'] ?? "-", labelFont),
                        _infoTile("Kaynak Inch", spool['inch'] ?? "-", labelFont),
                        _infoTile("Kaynak Türü", spool['type'] ?? "-", labelFont),
                        _infoTile("Not", spool['note'] ?? "-", labelFont),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 40)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _sectionTitle(String title, double fontSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoTile(String label, String value, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("$label:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize))),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: fontSize))),
        ],
      ),
    );
  }
}
