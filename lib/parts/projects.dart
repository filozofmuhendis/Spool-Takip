import 'package:flutter/material.dart';
import 'package:spool/parts/spool_detailing.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Map<String, String>> projects = [
    {'name': 'Galata Tersanesi - Yağlama Devresi', 'status': 'Tamamlandı', 'date': '12/05/2025'},
    {'name': 'Haliç Tersanesi - Soğutma Devresi', 'status': 'İşlemde', 'date': '10/05/2025'},
    {'name': 'Yalova Tersanesi - Su Devresi', 'status': 'Beklemede', 'date': '08/05/2025'},
    {'name': 'Sedef Tersanesi - Hidrolik Devresi', 'status': 'Sevkiyata Hazır', 'date': '05/05/2025'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Projelerim"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(project['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text("Durum: ${project['status']}\nTarih: ${project['date']}"),
                trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF186bfd)),
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
    );
  }
}

class ProjectDetailsPage extends StatelessWidget {
  final Map<String, String> project;

  ProjectDetailsPage({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project['name']!),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Proje Detayları", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Proje Adı: ${project['name']}"),
            Text("Durum: ${project['status']}"),
            Text("Başlangıç Tarihi: ${project['date']}"),
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
    );
  }
}