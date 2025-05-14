import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bildirimler',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              "Gelen Bildirimler",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Bildirim Listesi
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                  height: 1,
                ),
                itemCount: 6, // Örnek olarak 6 bildirim
                itemBuilder: (context, index) {
                  final notificationsData = [
                    {
                      'title': 'Teslimat Tamamlandı',
                      'message': 'Teslimat ST-1001 başarıyla tamamlandı.',
                      'time': '10:30 AM',
                      'type': 'success',
                    },
                    {
                      'title': 'Servis Gecikti',
                      'message': 'Dikim Makinesi için servis gecikti!',
                      'time': '09:15 AM',
                      'type': 'warning',
                    },
                    {
                      'title': 'Yeni Parti Eklendi',
                      'message': 'Yeni parti PRD-4503 sisteme eklendi.',
                      'time': '08:45 AM',
                      'type': 'info',
                    },
                    {
                      'title': 'Eksik Ürün Bildirimi',
                      'message': 'RT-1003 kodlu iadede 5 ürün eksik.',
                      'time': '08:20 AM',
                      'type': 'error',
                    },
                    {
                      'title': 'Bakım Zamanı Yaklaşıyor',
                      'message': 'Kesim Makinesi için bakım zamanı yaklaşıyor.',
                      'time': '07:50 AM',
                      'type': 'warning',
                    },
                    {
                      'title': 'Başarılı İşlem',
                      'message': 'RT-1002 kodlu iade başarıyla tamamlandı.',
                      'time': '07:30 AM',
                      'type': 'success',
                    },
                  ];

                  return ListTile(
                    leading: Icon(
                      _getNotificationIcon(notificationsData[index]['type']!),
                      color: _getNotificationColor(notificationsData[index]['type']!),
                    ),
                    title: Text(
                      notificationsData[index]['title']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      notificationsData[index]['message']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    trailing: Text(
                      notificationsData[index]['time']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      // Bildirim detay sayfasına yönlendirme
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bildirim türüne göre ikon belirleme
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  // Bildirim türüne göre renk belirleme
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
