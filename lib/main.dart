import 'package:flutter/material.dart';
import 'package:spool/about.dart';
import 'package:spool/parts/error_page.dart';
import 'package:spool/parts/job_order.dart';
import 'package:spool/parts/job_order_list.dart';
import 'package:spool/parts/notification.dart';
import 'package:spool/parts/login.dart';
import 'package:spool/parts/projects.dart';
import 'package:spool/parts/reports.dart';
import 'package:spool/parts/settings.dart';
import 'package:spool/parts/spool_tracking.dart';
import 'package:spool/parts/transaction_history.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zuyoysplupojazsaqejh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1eW95c3BsdXBvamF6c2FxZWpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NTYxOTUsImV4cCI6MjA2MzMzMjE5NX0.C8HQ_VieaIr9dqIWMWThZYXJ_MgKDp6xsUix4u94w7o',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spool Takip Sistemi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF186bfd)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => CustomLoginPage(),
        '/home': (_) => HomePage(),
        '/error': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return ErrorPage(message: args);
        },
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double gridSpacing = ResponsiveHelper.getResponsiveWidth(context, screenWidth > 600 ? 20 : 10);
    int crossAxisCount = screenWidth > 900 ? 5 : screenWidth > 600 ? 4 : 2;
    double cardIconSize = ResponsiveHelper.getResponsiveWidth(context, 40);
    double cardFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 12);
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AtölyeAkış',
          style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20), color: Colors.white),
        ),
        backgroundColor: Color(0xFF186bfd),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white, size: cardIconSize),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveWidth(context, 8)),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/user.png'),
              radius: ResponsiveHelper.getResponsiveWidth(context, 18),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF186bfd)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: ResponsiveHelper.getResponsiveWidth(context, 40),
                      backgroundImage: AssetImage('assets/user.png'),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 10)),
                    Text(
                      'AtölyeAkış',
                      style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24), fontWeight: FontWeight.bold),
                    ),
                  ],
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
            Divider(),
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
        padding: EdgeInsets.all(padding),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: 7,
          itemBuilder: (context, index) {
            final sections = [
              {'title': 'Projeler', 'icon': Icons.fact_check_outlined, 'path': ProjectsPage()},
              {'title': 'Üretim İşlemleri', 'icon': Icons.track_changes, 'path': SpoolTrackingPage()},
              {'title': 'İşlem Geçmişi', 'icon': Icons.business, 'path': TransactionHistoryPage()},
              {'title': 'İş Emri Oluştur', 'icon': Icons.account_tree_sharp, 'path': JobOrderPage()},
              {'title': 'İş Emri Uygula', 'icon': Icons.check_box, 'path': JobOrderListPage(workerId: currentUserId ?? 'default')},
              {'title': 'Raporlar', 'icon': Icons.assignment_return, 'path': ReportsPerformancePage()},
              {'title': 'Bildirimler', 'icon': Icons.notification_important, 'path': NotificationsPage()},
            ];

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardRadius),
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
                      size: cardIconSize,
                      color: Color(0xFF186bfd),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 10)),
                    Text(
                      sections[index]['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: cardFontSize, fontWeight: FontWeight.bold),
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
