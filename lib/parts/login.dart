import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:spool/parts/role_helper.dart';

class CustomLoginPage extends StatefulWidget {
  @override
  _CustomLoginPageState createState() => _CustomLoginPageState();
}

class _CustomLoginPageState extends State<CustomLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  bool _isPasswordVisible = false;
  bool loading = false;
  String? _errorMessage;
  final supabase = Supabase.instance.client;

  void toggleMode() => setState(() => isLogin = !isLogin);

  Future<void> handleAuth() async {
    setState(() {
      loading = true;
      _errorMessage = null;
    });
    
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen tüm alanları doldurunuz';
        loading = false;
      });
      return;
    }

    try {
      if (isLogin) {
        final response = await supabase.auth.signInWithPassword(email: email, password: password);
        
        if (response.user != null) {
          await _ensureUserProfile(response.user!);
        }
      } else {
        final response = await supabase.auth.signUp(email: email, password: password);
        
        if (response.user != null) {
          await _createUserProfile(response.user!);
        }
      }

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Giriş/Kayıt sırasında hata oluştu: ${e.toString()}';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _ensureUserProfile(User user) async {
    try {
      // Kullanıcının rolünü kontrol et ve gerekirse ayarla
      final userRole = await RoleHelper.getUserRole(user);
      
      // Eğer raw_user_meta_data'da rol yoksa, varsayılan rolü ayarla
      if (user.userMetadata?['role'] == null) {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'role': RoleHelper.getRoleString(userRole),
              'username': user.userMetadata?['username'] ?? user.email?.split('@')[0] ?? 'Kullanıcı',
            },
          ),
        );
      }

      // Users tablosunda kullanıcı kaydını kontrol et/oluştur
      try {
        await supabase
            .from('users')
            .upsert({
              'id': user.id,
              'email': user.email,
              'username': user.userMetadata?['username'] ?? user.email?.split('@')[0] ?? 'Kullanıcı',
              'role': RoleHelper.getRoleString(userRole),
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
      } catch (e) {
        print('Users tablosu güncellenirken hata: $e');
        // Tablo yoksa geçici olarak atla
      }
    } catch (e) {
      print('Profil kontrolü sırasında hata: $e');
      if (e.toString().contains('does not exist')) {
        setState(() {
          _errorMessage = 'Veritabanı tablosu bulunamadı. Lütfen Supabase ayarlarını kontrol edin.';
        });
        return;
      }
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      // Yeni kullanıcı için varsayılan rolü ayarla (worker)
      final defaultRole = UserRole.worker;
      
      // raw_user_meta_data'ya rol bilgisini ekle
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'role': RoleHelper.getRoleString(defaultRole),
            'username': user.userMetadata?['username'] ?? user.email?.split('@')[0] ?? 'Kullanıcı',
          },
        ),
      );

      // Users tablosunda kullanıcı kaydını oluştur
      try {
        await supabase
            .from('users')
            .upsert({
              'id': user.id,
              'email': user.email,
              'username': user.userMetadata?['username'] ?? user.email?.split('@')[0] ?? 'Kullanıcı',
              'role': RoleHelper.getRoleString(defaultRole),
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
      } catch (e) {
        print('Users tablosu oluşturulurken hata: $e');
        // Tablo yoksa geçici olarak atla
      }
    } catch (e) {
      print('Profil oluşturma hatası: $e');
      if (e.toString().contains('does not exist')) {
        setState(() {
          _errorMessage = 'Veritabanı tablosu bulunamadı. Lütfen Supabase ayarlarını kontrol edin.';
        });
        return;
      }
      setState(() {
        _errorMessage = 'Profil oluşturulamadı: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 24);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 15);
    double logoSize = ResponsiveHelper.getResponsiveWidth(context, 80);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 24);
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double inputFont = ResponsiveHelper.getResponsiveFontSize(context, 16);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
        child: Padding(
              padding: EdgeInsets.all(padding),
          child: Card(
            elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
            child: Padding(
                  padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                      // Logo
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/logo.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 20)),
                      Text(
                        isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                        style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold, color: Color(0xFF186bfd)),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 20)),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: inputFont),
                        decoration: InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                      TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(fontSize: inputFont),
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: inputFont),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 20)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                    onPressed: loading ? null : handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF186bfd),
                            padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveHeight(context, 16)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                    child: loading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                                  style: TextStyle(fontSize: buttonFont, color: Colors.white),
                                ),
                        ),
                  ),
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
                  TextButton(
                    onPressed: toggleMode,
                        child: Text(
                          isLogin ? 'Hesabınız yok mu? Kayıt olun' : 'Zaten hesabınız var mı? Giriş yapın',
                          style: TextStyle(color: Color(0xFF186bfd), fontSize: inputFont),
                        ),
                  ),
                ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}