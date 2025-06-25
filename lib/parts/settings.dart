import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';

class SettingsProfilePage extends StatefulWidget {
  @override
  _SettingsProfilePageState createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  TextEditingController _usernameController = TextEditingController(text: "Kullanıcı Adı");
  TextEditingController _emailController = TextEditingController(text: "user@example.com");
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 24);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonPadding = ResponsiveHelper.getResponsiveHeight(context, 16);

    return Scaffold(
      appBar: AppBar(
        title: Text("Ayarlar ve Profil Yönetimi", style: TextStyle(fontSize: titleFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profil Bilgileri",
                style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
              TextField(
                controller: _usernameController,
                style: TextStyle(fontSize: labelFont),
                decoration: InputDecoration(
                  labelText: "Kullanıcı Adı",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
              TextField(
                controller: _emailController,
                style: TextStyle(fontSize: labelFont),
                decoration: InputDecoration(
                  labelText: "E-posta",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 32)),
              SwitchListTile(
                title: Text("Bildirimleri Aç", style: TextStyle(fontSize: labelFont)),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
                activeColor: Color(0xFF186bfd),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 32)),
              ElevatedButton(
                onPressed: () {},
                child: Text("Şifre Değiştir", style: TextStyle(fontSize: buttonFont)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF186bfd),
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
              ElevatedButton(
                onPressed: () {},
                child: Text("Çıkış Yap", style: TextStyle(fontSize: buttonFont)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}