import 'package:supabase_flutter/supabase_flutter.dart';

// Kullanıcı rol enum'u
enum UserRole {
  admin,      // Yönetici - Tüm yetkilere sahip
  supervisor, // Süpervizör - Proje ve rapor yönetimi
  worker,     // İşçi - Sadece kendi işlerini görebilir
  viewer      // Görüntüleyici - Sadece raporları görebilir
}

// Kullanıcı modeli
class UserModel {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final bool notificationsEnabled;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? 'Kullanıcı',
      email: map['email'] ?? '',
      role: _parseRole(map['role'] ?? 'worker'),
      notificationsEnabled: map['notifications_enabled'] ?? true,
    );
  }

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'supervisor':
        return UserRole.supervisor;
      case 'viewer':
        return UserRole.viewer;
      case 'worker':
      default:
        return UserRole.worker;
    }
  }
}

class RoleHelper {
  static var supabase = Supabase.instance.client;

  // Kullanıcının rolünü Supabase'den al
  static Future<UserRole> getUserRole(User user) async {
    try {
      // raw_user_meta_data'dan rol bilgisini al
      final userMetadata = user.userMetadata;
      final role = userMetadata?['role'] as String?;

      if (role != null) {
        return _parseRole(role);
      }

      // Eğer raw_user_meta_data'da rol yoksa, users tablosundan kontrol et
      try {
        final response = await supabase
            .from('users')
            .select('role')
            .eq('id', user.id)
            .single();

        return _parseRole(response['role'] ?? 'worker');
      } catch (e) {
        print('Users tablosundan rol alınamadı: $e');
        return UserRole.worker; // Varsayılan rol
      }
    } catch (e) {
      print('Rol alınırken hata: $e');
      return UserRole.worker; // Varsayılan rol
    }
  }

  // Kullanıcı modelini oluştur
  static Future<UserModel> createUserModel(User user) async {
    final role = await getUserRole(user);

    return UserModel(
      id: user.id,
      username: user.userMetadata?['username'] ?? user.email?.split('@')[0] ?? 'Kullanıcı',
      email: user.email ?? '',
      role: role,
    );
  }

  // Rol string'ini enum'a çevir
  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'supervisor':
        return UserRole.supervisor;
      case 'viewer':
        return UserRole.viewer;
      case 'worker':
      default:
        return UserRole.worker;
    }
  }

  // Rol string'ini döndür
  static String getRoleString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.supervisor:
        return 'supervisor';
      case UserRole.worker:
        return 'worker';
      case UserRole.viewer:
        return 'viewer';
    }
  }

  // Rol Türkçe adını döndür
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Yönetici';
      case UserRole.supervisor:
        return 'Süpervizör';
      case UserRole.worker:
        return 'İşçi';
      case UserRole.viewer:
        return 'Görüntüleyici';
    }
  }

  // Kullanıcının belirli bir özelliğe erişim yetkisi var mı kontrol et
  static bool hasPermission(UserRole userRole, String permission) {
    switch (permission) {
      case 'user_management':
        return userRole == UserRole.admin;
      case 'project_management':
        return userRole == UserRole.admin || userRole == UserRole.supervisor;
      case 'job_order_management':
        return userRole == UserRole.admin || userRole == UserRole.supervisor;
      case 'inventory_management':
        return userRole == UserRole.admin || userRole == UserRole.supervisor;
      case 'quality_control':
        return userRole == UserRole.admin || userRole == UserRole.supervisor;
      case 'production_planning':
        return userRole == UserRole.admin || userRole == UserRole.supervisor;
      case 'equipment_tracking':
        return userRole == UserRole.admin || userRole == UserRole.supervisor;
      case 'shipping_management':
        return userRole == UserRole.admin || userRole == UserRole.supervisor;
      case 'reports':
        return true; // Tüm roller raporları görebilir
      case 'spool_tracking':
        return true; // Tüm roller spool takibini görebilir
      case 'job_tracking':
        return true; // Tüm roller iş takibini görebilir
      case 'notifications':
        return true; // Tüm roller bildirimleri görebilir
      case 'settings':
        return true; // Tüm roller ayarları görebilir
      default:
        return false;
    }
  }

  // Kullanıcının rolünü güncelle
  static Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      // Önce users tablosunda güncelle
      await supabase
          .from('users')
          .upsert({
        'id': userId,
        'role': getRoleString(newRole),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // raw_user_meta_data'yı güncelle
      await supabase.auth.updateUser(
        UserAttributes(
          data: {'role': getRoleString(newRole)},
        ),
      );
    } catch (e) {
      print('Rol güncellenirken hata: $e');
      throw e;
    }
  }
}