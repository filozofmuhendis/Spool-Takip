import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double logoSize = ResponsiveHelper.getResponsiveWidth(context, 100);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 22);
    double sectionFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hakkında',
          style: TextStyle(fontSize: sectionFont),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Center(
              child: Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/logo.jpg'), // Logonun yolu
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 10)),
            // İletişim Bilgileri Başlık
            Text(
              'Bu uygulamanın tasarımı ve kodlanması Filozof Mühendis tarafından yapılmıştır.',
              style: TextStyle(
                fontSize: sectionFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 10)),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 20)),

            // Uygulama Hakkında Başlık
            Text(
              'Uygulama Hakkında',
              style: TextStyle(
                fontSize: titleFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 10)),

            // Açıklama Metni
            Text(
              'Bu uygulama, üretim süreçlerinizi takip etmek ve yönetmek için tasarlanmıştır. Kullanıcı dostu arayüzü ve kapsamlı özellikleriyle iş süreçlerinizi kolaylaştırır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelFont,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 20)),

            // İletişim Bilgileri Başlık
            Text(
              'İletişim',
              style: TextStyle(
                fontSize: sectionFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 10)),

            // İletişim Bilgileri
            Text(
              'E-posta: filozofmuhendiss@gmail.com\nTelefon: +90 530 304 4461',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelFont,
                color: Colors.grey[700],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
