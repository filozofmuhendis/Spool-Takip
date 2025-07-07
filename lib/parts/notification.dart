import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'error_page.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
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
      final result = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      setState(() {
        notifications = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Bildirimler yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 15);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 18);
    double subtitleFont = ResponsiveHelper.getResponsiveFontSize(context, 14);
    double iconSize = ResponsiveHelper.getResponsiveWidth(context, 32);
    double appBarFont = ResponsiveHelper.getResponsiveFontSize(context, 20);

    return Scaffold(
      appBar: AppBar(
        title: Text("Bildirimler", style: TextStyle(fontSize: appBarFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? ErrorPage(
                    message: errorMessage!,
                    errorType: ErrorType.data,
                    onRetry: fetchNotifications,
                  )
                : notifications.isEmpty
                    ? Center(child: Text('Hiç bildiriminiz yok.', style: TextStyle(fontSize: titleFont)))
                    : RefreshIndicator(
                        onRefresh: fetchNotifications,
                        child: ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(cardRadius),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.only(bottom: padding),
                              child: ListTile(
                                leading: Icon(
                                  _getNotificationIcon(notification['type'] ?? 'info'),
                                  color: _getNotificationColor(notification['type'] ?? 'info'),
                                  size: iconSize,
                                ),
                                title: Text(notification['title'] ?? '-', style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold)),
                                subtitle: Text(notification['message'] ?? '-', style: TextStyle(fontSize: subtitleFont)),
                                trailing: Text(
                                  notification['created_at']?.toString().substring(0, 10) ?? '-',
                                  style: TextStyle(color: Colors.black, fontSize: subtitleFont),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}