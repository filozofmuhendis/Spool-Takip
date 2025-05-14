import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Bildirimler"),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: EdgeInsets.only(bottom: 16),
              //color: _getNotificationColor(notification['type']).withOpacity(0.1),
              child: ListTile(
                leading: Icon(
                  _getNotificationIcon(notification['type']),
                  color: _getNotificationColor(notification['type']),
                  size: 32,
                ),
                title: Text(notification['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(notification['message']),
                trailing: Text(notification['date'], style: TextStyle(color: Colors.black)),
              ),
            );
          },
        ),
      ),
    );
  }
}