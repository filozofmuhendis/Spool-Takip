import 'package:flutter/material.dart';
import 'package:spool/parts/spool_detailing.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Map<String, dynamic>> projects = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Kullanıcı oturumu bulunamadı.';
          loading = false;
        });
        return;
      }
      
      // Tüm projeleri getir (sadece kullanıcının kendi projelerini değil)
      final result = await Supabase.instance.client
          .from('projects')
          .select()
          .order('created_at', ascending: false);
          
      setState(() {
        projects = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Projeler yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 15);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 18);
    double subtitleFont = ResponsiveHelper.getResponsiveFontSize(context, 14);
    double iconSize = ResponsiveHelper.getResponsiveWidth(context, 24);
    double appBarFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonPadding = ResponsiveHelper.getResponsiveHeight(context, 16);

    return Scaffold(
      appBar: AppBar(
        title: Text("Projelerim", style: TextStyle(fontSize: appBarFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: titleFont)))
                : projects.isEmpty
                    ? Center(child: Text('Hiç projeniz yok.', style: TextStyle(fontSize: titleFont)))
                    : RefreshIndicator(
                        onRefresh: fetchProjects,
                        child: ListView.builder(
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(cardRadius),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.only(bottom: padding),
                              child: ListTile(
                                title: Text(project['name'] ?? '-', style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold)),
                                subtitle: Text("Durum: ${project['status'] ?? '-'}\nTarih: ${project['created_at']?.toString().substring(0, 10) ?? '-'}", style: TextStyle(fontSize: subtitleFont)),
                                trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF186bfd), size: iconSize),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectDetailsPage(project: project),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

class ProjectDetailsPage extends StatelessWidget {
  final Map<String, dynamic> project;

  ProjectDetailsPage({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project['name'] ?? '-'),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Proje Detayları", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Proje Adı: ${project['name'] ?? '-'}"),
            Text("Durum: ${project['status'] ?? '-'}"),
            Text("Başlangıç Tarihi: ${project['created_at']?.toString().substring(0, 10) ?? '-'}"),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpoolDetailPage(spoolData: {
                      'spoolNumber': 'SP1234',
                      'material': 'AISI316',
                      'diameter': 'DN100',
                      'weight': '12.4kg',
                      'barcode': 'SP00123',
                      'history': [
                        {'type': 'İmalat', 'date': '2025-05-01', 'person': 'Ahmet Usta'},
                        {'type': 'Kaynak', 'date': '2025-05-02', 'person': 'Ali Usta'},
                      ],
                      'documents': [], // File nesneleri eklenecek
                      'ek': '2',
                      'flans': '1',
                      'manson': '3',
                      'inch': '42',
                      'type': 'Argon',
                      'note': 'Özel kaynak kullanıldı.',
                    }),
                  ),
                );
              },
              child: Text("Spool Listesini Gör"),
            ),
          ],
        ),
      ),
    );
  }
}