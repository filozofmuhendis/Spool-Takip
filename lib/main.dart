import 'package:flutter/material.dart';
import 'package:spool/about.dart';
import 'package:spool/parts/error_page.dart';
import 'package:spool/parts/job_order.dart';
import 'package:spool/parts/job_order_list.dart';
import 'package:spool/parts/job_order_tracking.dart';
import 'package:spool/parts/notification.dart';
import 'package:spool/parts/login.dart';
import 'package:spool/parts/projects.dart';
import 'package:spool/parts/reports.dart';
import 'package:spool/parts/settings.dart';
import 'package:spool/parts/spool_tracking.dart';
import 'package:spool/parts/transaction_history.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://YOUR-PROJECT.supabase.co',
    anonKey: 'YOUR-ANON-KEY',
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (_) => CustomLoginPage(),
      '/home': (_) => JobOrderListPage(workerId: 'örnek-id'),
      '/error': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as String;
        return ErrorPage(message: args);
      },
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //initialRoute: '/',
      //routes: {
      //  '/home': (context) => HomePage(),
      //  '/projects': (context) => ProjectsPage(),
      //  '/error': (context) {
      //    final args = ModalRoute.of(context)!.settings.arguments as String;
      //    return ErrorPage(message: args);
      //  },
      //},
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: CustomLoginPage(),//HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double gridSpacing = screenWidth > 600 ? 20 : 10; // Responsive spacing

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AtölyeAkış',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.tealAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Bildirimler açılır
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/user.png'), // Profil fotoğrafı
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Center(
                child: Text(
                  'Menü',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ayarlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_box_rounded),
              title: Text('Uygulama Hakkında'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            //Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await _signOut(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 600 ? 4 : 2, // Tablet ve telefon için
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
            childAspectRatio: 1.0, // Kare şeklinde kartlar
          ),
          itemCount: 7, // Bölüm sayısı
          itemBuilder: (context, index) {
            final sections = [
              {'title': 'Projeler', 'icon': Icons.fact_check_outlined, 'path': ProjectsPage()},
              {'title': 'Üretim İşlemleri', 'icon': Icons.track_changes, 'path': SpoolTrackingPage()},
              {'title': 'İşlem Geçmişi', 'icon': Icons.business, 'path': TransactionHistoryPage()},
              {'title': 'İş Emri Oluştur', 'icon': Icons.account_tree_sharp, 'path': JobOrderPage()},
              {'title': 'İş Emri Uygula', 'icon': Icons.check_box, 'path': JobOrderListPage(workerId: 'sdvsdv',)},
              {'title': 'Raporlar', 'icon': Icons.assignment_return, 'path': ReportsPerformancePage()},
              {'title': 'Bildirimler', 'icon': Icons.notification_important, 'path': NotificationsPage()},
            ];

            return Card( 
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => sections[index]['path'] as Widget),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      sections[index]['icon'] as IconData?,
                      size: 40,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 10),
                    Text(
                      sections[index]['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _signOut(BuildContext context) async {
  await Supabase.instance.client.auth.signOut();
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
