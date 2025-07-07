import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpoolJobOrderPage extends StatefulWidget {
  @override
  _SpoolJobOrderPageState createState() => _SpoolJobOrderPageState();
}

class _SpoolJobOrderPageState extends State<SpoolJobOrderPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _circuitController = TextEditingController();
  final TextEditingController _spoolNumberController = TextEditingController();
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  List<Map<String, dynamic>> spoolList = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSpools();
  }

  Future<void> fetchSpools() async {
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
          .from('spools')
          .select()
          .eq('created_by', user.id)
          .order('created_at', ascending: false);
      setState(() {
        spoolList = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Spool listesi yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  Future<void> addSpool() async {
    if (_spoolNumberController.text.isEmpty ||
        _diameterController.text.isEmpty ||
        _materialController.text.isEmpty ||
        _weightController.text.isEmpty) return;
    setState(() => loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final newSpool = {
        'spool_number': _spoolNumberController.text,
        'diameter': _diameterController.text,
        'material': _materialController.text,
        'weight': _weightController.text,
        'barcode': "SP${DateTime.now().millisecondsSinceEpoch % 100000}",
        'created_by': user.id,
        'circuit': _circuitController.text,
      };
      await supabase.from('spools').insert(newSpool);
      _spoolNumberController.clear();
      _diameterController.clear();
      _materialController.clear();
      _weightController.clear();
      await fetchSpools();
    } catch (e) {
      setState(() {
        errorMessage = 'Spool eklenirken hata oluştu:\n${e.toString()}';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 15);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonPadding = ResponsiveHelper.getResponsiveHeight(context, 14);

    return Scaffold(
      appBar: AppBar(
        title: Text("Spool İş Emri Oluştur", style: TextStyle(fontSize: labelFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: labelFont)))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Devre Adı", style: TextStyle(fontWeight: FontWeight.bold, fontSize: labelFont)),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 4)),
                        TextField(
                          controller: _circuitController,
                          style: TextStyle(fontSize: labelFont),
                          decoration: InputDecoration(
                            hintText: "Örn: Yakıt Hattı",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                        Text("Spool Bilgileri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: labelFont)),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
                        TextField(
                          controller: _spoolNumberController,
                          style: TextStyle(fontSize: labelFont),
                          decoration: InputDecoration(
                            labelText: "Spool No",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _diameterController,
                                style: TextStyle(fontSize: labelFont),
                                decoration: InputDecoration(
                                  labelText: "Çap",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 8)),
                            Expanded(
                              child: TextField(
                                controller: _materialController,
                                style: TextStyle(fontSize: labelFont),
                                decoration: InputDecoration(
                                  labelText: "Malzeme",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
                        TextField(
                          controller: _weightController,
                          style: TextStyle(fontSize: labelFont),
                          decoration: InputDecoration(
                            labelText: "Ağırlık (kg)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 12)),
                        ElevatedButton.icon(
                          onPressed: addSpool,
                          icon: Icon(Icons.add, size: ResponsiveHelper.getResponsiveWidth(context, 20)),
                          label: Text("Spool Ekle", style: TextStyle(fontSize: buttonFont)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF186bfd),
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),
                        Text("Eklenen Spool Listesi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: labelFont)),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: spoolList.length,
                          itemBuilder: (context, index) {
                            final item = spoolList[index];
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
                              child: ListTile(
                                title: Text("Spool No: ${item['spool_number']} • Barkod: ${item['barcode']}", style: TextStyle(fontSize: labelFont)),
                                subtitle: Text("Çap: ${item['diameter']} | Malzeme: ${item['material']} | Ağırlık: ${item['weight']}kg", style: TextStyle(fontSize: labelFont)),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 24)),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.print, size: ResponsiveHelper.getResponsiveWidth(context, 20)),
                          label: Text("Tüm Barkodları Yazdır", style: TextStyle(fontSize: buttonFont)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF186bfd),
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
