import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hakkında',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/logo.jpg'), // Logonun yolu
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            // İletişim Bilgileri Başlık
            Text(
              'Bu uygulamanın tasarımı ve kodlanması Filozof Mühendis tarafından yapılmıştır.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 20),

            // Uygulama Hakkında Başlık
            Text(
              'Uygulama Hakkında',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Açıklama Metni
            Text(
              'Bu uygulama, üretim süreçlerinizi takip etmek ve yönetmek için tasarlanmıştır. Kullanıcı dostu arayüzü ve kapsamlı özellikleriyle iş süreçlerinizi kolaylaştırır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),

            // İletişim Bilgileri Başlık
            Text(
              'İletişim',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // İletişim Bilgileri
            Text(
              'E-posta: filozofmuhendiss@gmail.com\nTelefon: +90 530 304 4461',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
