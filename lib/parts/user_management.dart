import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:spool/parts/role_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final result = await supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        users = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Kullanıcılar yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  String _getRoleDisplayName(String role) {
    final userRole = _parseRole(role);
    return RoleHelper.getRoleDisplayName(userRole);
  }

  UserRole _parseRole(String role) {
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'supervisor':
        return Colors.orange;
      case 'worker':
        return Colors.blue;
      case 'viewer':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    setState(() => loading = true);
    try {
      await supabase
          .from('users')
          .update({'role': newRole})
          .eq('id', userId);
      await fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı rolü güncellendi')),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Rol güncellenirken hata oluştu:\n${e.toString()}';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kullanıcıyı Sil'),
        content: Text('Bu kullanıcıyı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => loading = true);
      try {
        await supabase.from('users').delete().eq('id', userId);
        await fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı silindi')),
        );
      } catch (e) {
        setState(() {
          errorMessage = 'Kullanıcı silinirken hata oluştu:\n${e.toString()}';
        });
      } finally {
        setState(() => loading = false);
      }
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    return users.where((user) {
      final username = user['username']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final role = _getRoleDisplayName(user['role'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      return username.contains(query) ||
          email.contains(query) ||
          role.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double subtitleFont = ResponsiveHelper.getResponsiveFontSize(context, 14);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 12);

    return Scaffold(
      appBar: AppBar(
        title: Text("Kullanıcı Yönetimi", style: TextStyle(fontSize: titleFont)),
        backgroundColor: Color(0xFF186bfd),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchUsers,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: subtitleFont),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchUsers,
                child: Text('Tekrar Dene'),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // Arama Çubuğu
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Kullanıcı ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

            // Kullanıcı Sayısı
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF186bfd).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.people, color: Color(0xFF186bfd)),
                  SizedBox(width: 8),
                  Text(
                    '${filteredUsers.length} kullanıcı bulundu',
                    style: TextStyle(
                      fontSize: subtitleFont,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF186bfd),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

            // Kullanıcı Listesi
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      searchQuery.isEmpty
                          ? 'Henüz kullanıcı bulunmuyor'
                          : 'Arama sonucu bulunamadı',
                      style: TextStyle(fontSize: subtitleFont, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/user.png'),
                        backgroundColor: _getRoleColor(user['role'] ?? 'worker'),
                      ),
                      title: Text(
                        user['username'] ?? 'Kullanıcı',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['email'] ?? ''),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user['role'] ?? 'worker').withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getRoleDisplayName(user['role'] ?? 'worker'),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getRoleColor(user['role'] ?? 'worker'),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showEditUserDialog(user);
                          } else if (value == 'delete') {
                            await deleteUser(user['id']);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Düzenle'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Sil', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'] ?? 'worker';
    final usernameController = TextEditingController(text: user['username'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Kullanıcı Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('Yönetici')),
                  DropdownMenuItem(value: 'supervisor', child: Text('Süpervizör')),
                  DropdownMenuItem(value: 'worker', child: Text('İşçi')),
                  DropdownMenuItem(value: 'viewer', child: Text('Görüntüleyici')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await supabase.from('users').update({
                  'username': usernameController.text,
                  'email': emailController.text,
                  'role': selectedRole,
                }).eq('id', user['id']);
                Navigator.pop(context);
                await fetchUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kullanıcı güncellendi')),
                );
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
