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
import 'package:spool/parts/user_management.dart' show UserManagementPage;
import 'package:spool/parts/spool_job_order.dart';
import 'package:spool/parts/quality_control.dart';
import 'package:spool/parts/inventory.dart';
import 'package:spool/parts/production_planning.dart';
import 'package:spool/parts/equipment_tracking.dart';
import 'package:spool/parts/project_management.dart';
import 'package:spool/parts/job_order_management.dart';
import 'package:spool/parts/job_tracking.dart';
import 'package:spool/parts/shipping_management.dart';
import 'package:spool/parts/inventory_management.dart';
import 'package:spool/parts/spool_details_management.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:spool/parts/role_helper.dart';

// Menü öğesi modeli
class MenuItem {
  final String title;
  final IconData icon;
  final Widget page;
  final List<UserRole> allowedRoles;

  MenuItem({
    required this.title,
    required this.icon,
    required this.page,
    required this.allowedRoles,
  });
}

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
      title: 'AtölyeAkış',
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
  UserModel? currentUser;
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.';
          loading = false;
        });
        return;
      }

      // RoleHelper kullanarak kullanıcı modelini oluştur
      final userModel = await RoleHelper.createUserModel(user);

      setState(() {
        currentUser = userModel;
        loading = false;
      });

      // Arka planda tablo oluşturmayı dene
      _tryCreateUsersTable(user);
      
    } catch (e) {
      print('Kullanıcı bilgileri yüklenirken hata: $e');
      setState(() {
        errorMessage = 'Kullanıcı bilgileri yüklenirken hata oluştu:\n${e.toString()}\n\nLütfen tekrar giriş yapmayı deneyin.';
        loading = false;
      });
    }
  }

  // Arka planda users tablosunu oluşturmayı dene
  Future<void> _tryCreateUsersTable(User user) async {
    try {
      // Önce tablo var mı kontrol et
      await Supabase.instance.client
          .from('users')
          .select('id')
          .limit(1);
    } catch (e) {
      if (e.toString().contains('does not exist')) {
        print('Users tablosu bulunamadı. Lütfen Supabase Dashboard\'da SQL çalıştırın.');
        // Kullanıcıya bilgi ver
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Veritabanı tablosu eksik. Lütfen Supabase Dashboard\'da SQL çalıştırın.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  // Kullanıcının rolüne göre menü öğelerini filtrele
  List<MenuItem> getFilteredMenuItems() {
    if (currentUser == null) return [];

    return allMenuItems.where((item) {
      return item.allowedRoles.contains(currentUser!.role);
    }).toList();
  }

  // Tüm menü öğeleri
  List<MenuItem> get allMenuItems => [
    MenuItem(
      title: 'Projeler',
      icon: Icons.folder,
      page: ProjectsPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor, UserRole.worker, UserRole.viewer],
    ),
    MenuItem(
      title: 'İş Emirleri',
      icon: Icons.assignment,
      page: JobOrderListPage(workerId: ''),
      allowedRoles: [UserRole.admin, UserRole.supervisor, UserRole.worker],
    ),
    MenuItem(
      title: 'Spool Takibi',
      icon: Icons.track_changes,
      page: SpoolTrackingPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor, UserRole.worker, UserRole.viewer],
    ),
    MenuItem(
      title: 'İş Takibi',
      icon: Icons.work,
      page: JobTrackingPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor, UserRole.worker, UserRole.viewer],
    ),
    MenuItem(
      title: 'Raporlar',
      icon: Icons.analytics,
      page: ReportsPerformancePage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor, UserRole.worker, UserRole.viewer],
    ),
    MenuItem(
      title: 'Bildirimler',
      icon: Icons.notifications,
      page: NotificationsPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor, UserRole.worker, UserRole.viewer],
    ),
    MenuItem(
      title: 'Kullanıcı Yönetimi',
      icon: Icons.people,
      page: UserManagementPage(),
      allowedRoles: [UserRole.admin],
    ),
    MenuItem(
      title: 'Proje Yönetimi',
      icon: Icons.manage_accounts,
      page: ProjectManagementPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor],
    ),
    MenuItem(
      title: 'İş Emri Yönetimi',
      icon: Icons.assignment_turned_in,
      page: JobOrderManagementPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor],
    ),
    MenuItem(
      title: 'Envanter Yönetimi',
      icon: Icons.inventory,
      page: InventoryManagementPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor],
    ),
    MenuItem(
      title: 'Kalite Kontrol',
      icon: Icons.verified,
      page: QualityControlPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor],
    ),
    MenuItem(
      title: 'Üretim Planlama',
      icon: Icons.schedule,
      page: ProductionPlanningPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor],
    ),
    MenuItem(
      title: 'Ekipman Takibi',
      icon: Icons.build,
      page: EquipmentTrackingPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor],
    ),
    MenuItem(
      title: 'Sevkiyat Yönetimi',
      icon: Icons.local_shipping,
      page: ShippingManagementPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor],
    ),
    MenuItem(
      title: 'Spool Detay Yönetimi',
      icon: Icons.details,
      page: SpoolDetailsManagementPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor],
    ),
    MenuItem(
      title: 'İşlem Geçmişi',
      icon: Icons.history,
      page: TransactionHistoryPage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor, UserRole.worker, UserRole.viewer],
    ),
    MenuItem(
      title: 'Ayarlar',
      icon: Icons.settings,
      page: SettingsProfilePage(),
      allowedRoles: [UserRole.admin, UserRole.supervisor, UserRole.worker, UserRole.viewer],
    ),
  ];

  // Kullanıcının rolünü Türkçe olarak getir
  String _getRoleDisplayName(UserRole role) {
    return RoleHelper.getRoleDisplayName(role);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Hata'),
          backgroundColor: Color(0xFF186bfd),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _getCurrentUser,
                      child: Text('Tekrar Dene'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: Text('Giriş Sayfasına Dön'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('Kullanıcı bilgileri yüklenemedi')),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double gridSpacing = ResponsiveHelper.getResponsiveWidth(context, screenWidth > 600 ? 20 : 10);
    int crossAxisCount = screenWidth > 900 ? 5 : screenWidth > 600 ? 4 : 2;
    double cardIconSize = ResponsiveHelper.getResponsiveWidth(context, 40);
    double cardFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 12);
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);

    final menuItems = getFilteredMenuItems();

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: ResponsiveHelper.getResponsiveWidth(context, 30),
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
                  Flexible(
                    child: Text(
                      currentUser!.username,
                      style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16), fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 4)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getRoleDisplayName(currentUser!.role),
                      style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10)),
                    ),
                  ),
                ],
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
            // Admin kullanıcılar için kullanıcı yönetimi
            if (currentUser!.role == UserRole.admin)
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Kullanıcı Yönetimi'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserManagementPage()),
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
        child: menuItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Bu rol için erişilebilir menü bulunmuyor',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => item.page),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: cardIconSize,
                            color: Color(0xFF186bfd),
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 10)),
                          Text(
                            item.title,
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
