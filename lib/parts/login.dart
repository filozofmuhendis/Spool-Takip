import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomLoginPage extends StatefulWidget {
  @override
  _CustomLoginPageState createState() => _CustomLoginPageState();
}

class _CustomLoginPageState extends State<CustomLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin=true;
  bool _isPasswordVisible = false;
  bool loading = false;
  String? _errorMessage;
  final supabase = Supabase.instance.client;

  void toggleMode() => setState(() => isLogin = !isLogin);

  Future<void> handleAuth() async {
    setState(() => loading = true);
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(email: email, password: password);
      } else {
        await supabase.auth.signUp(email: email, password: password);
      }

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          '/error',
          arguments: 'Giriş/Kayıt sırasında hata oluştu:\n${e.toString()}',
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isLogin ? 'Giriş Yap' : 'Kayıt Ol', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextField(controller: emailController, decoration: InputDecoration(labelText: 'E-posta')),
                  TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Şifre'), obscureText: true),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loading ? null : handleAuth,
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF186bfd)),
                    child: loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                  ),
                  TextButton(
                    onPressed: toggleMode,
                    child: Text(isLogin ? 'Hesabınız yok mu? Kayıt olun' : 'Zaten hesabınız var mı? Giriş yapın'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}