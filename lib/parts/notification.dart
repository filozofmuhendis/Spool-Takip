import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [
    {'title': 'Yeni Proje Eklendi', 'message': 'Galata Tersanesi - Yağlama Devresi başarıyla eklendi.', 'date': '08/05/2025', 'type': 'info'},
    {'title': 'Spool Tamamlandı', 'message': 'Spool A üretimi tamamlandı.', 'date': '08/05/2025', 'type': 'success'},
    {'title': 'Eksik Malzeme', 'message': 'Yalova Tersanesi için eksik malzeme bildirimi.', 'date': '07/05/2025', 'type': 'warning'},
    {'title': 'Sevkiyat Beklemede', 'message': 'Sedef Tersanesi sevkiyata hazır.', 'date': '06/05/2025', 'type': 'info'},
    {'title': 'Kalite Kontrol Hatası', 'message': 'Haliç Tersanesi için kalite kontrol hatası bulundu.', 'date': '05/05/2025', 'type': 'error'},
  ];

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
                  _getNotificationIcon(notification['type']),
                  color: _getNotificationColor(notification['type']),
                  size: iconSize,
                ),
                title: Text(notification['title'], style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold)),
                subtitle: Text(notification['message'], style: TextStyle(fontSize: subtitleFont)),
                trailing: Text(notification['date'], style: TextStyle(color: Colors.black, fontSize: subtitleFont)),
              ),
            );
          },
        ),
      ),
    );
  }
}