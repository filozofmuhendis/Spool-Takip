import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:spool/parts/role_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsProfilePage extends StatefulWidget {
  @override
  _SettingsProfilePageState createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  final supabase = Supabase.instance.client;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool notificationsEnabled = true;
  bool loading = true;
  String? errorMessage;
  UserRole currentRole = UserRole.worker;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Kullanıcı oturumu bulunamadı.';
          loading = false;
        });
        return;
      }

      // RoleHelper kullanarak kullanıcı modelini oluştur
      final userModel = await RoleHelper.createUserModel(user);
      
      _usernameController.text = userModel.username;
      _emailController.text = userModel.email;
      currentRole = userModel.role;
      isAdmin = currentRole == UserRole.admin;
      notificationsEnabled = userModel.notificationsEnabled;

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Profil yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  Future<void> updateUserProfile() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // raw_user_meta_data'yı güncelle
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'username': _usernameController.text,
            'role': RoleHelper.getRoleString(currentRole),
          },
        ),
      );

      // Users tablosunu güncelle
      try {
        await supabase.from('users').upsert({
          'id': user.id,
          'username': _usernameController.text,
          'email': _emailController.text,
          'notifications_enabled': notificationsEnabled,
          'role': RoleHelper.getRoleString(currentRole),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Users tablosu güncellenirken hata: $e');
        // Tablo yoksa geçici olarak atla
      }

      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil güncellendi.')));
    } catch (e) {
      setState(() {
        errorMessage = 'Profil güncellenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

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
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: labelFont)))
                : SingleChildScrollView(
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
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                        
                        // Rol Seçimi (Sadece admin kullanıcılar için)
                        if (isAdmin) ...[
                          Text(
                            "Kullanıcı Rolü",
                            style: TextStyle(fontSize: labelFont, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<UserRole>(
                                value: currentRole,
                                isExpanded: true,
                                items: UserRole.values.map((UserRole role) {
                                  return DropdownMenuItem<UserRole>(
                                    value: role,
                                    child: Text(
                                      RoleHelper.getRoleDisplayName(role),
                                      style: TextStyle(fontSize: labelFont),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (UserRole? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      currentRole = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                        ] else ...[
                          // Rol bilgisi (sadece görüntüleme)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.security, color: Color(0xFF186bfd)),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Mevcut Rol",
                                      style: TextStyle(fontSize: labelFont - 2, color: Colors.grey),
                                    ),
                                    Text(
                                      RoleHelper.getRoleDisplayName(currentRole),
                                      style: TextStyle(fontSize: labelFont, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                        ],

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
                          onPressed: updateUserProfile,
                          child: Text("Profili Kaydet", style: TextStyle(fontSize: buttonFont)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF186bfd),
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                        
                        // Rol Açıklamaları
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rol Yetkileri",
                                style: TextStyle(fontSize: labelFont, fontWeight: FontWeight.bold, color: Color(0xFF186bfd)),
                              ),
                              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
                              _buildRoleDescription("Yönetici", "Tüm modüllere erişim, kullanıcı yönetimi"),
                              _buildRoleDescription("Süpervizör", "Proje yönetimi, iş emri oluşturma, raporlar"),
                              _buildRoleDescription("İşçi", "Kendi işlerini görme, üretim işlemleri"),
                              _buildRoleDescription("Görüntüleyici", "Sadece raporları ve işlem geçmişini görme"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildRoleDescription(String role, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: Color(0xFF186bfd),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}