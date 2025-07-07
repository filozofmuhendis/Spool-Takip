import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EquipmentTrackingPage extends StatefulWidget {
  @override
  _EquipmentTrackingPageState createState() => _EquipmentTrackingPageState();
}

class _EquipmentTrackingPageState extends State<EquipmentTrackingPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> equipment = [];
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await Future.wait([
        fetchEquipment(),
        fetchUsers(),
      ]);
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  Future<void> fetchEquipment() async {
    final result = await supabase
        .from('equipment_tracking')
        .select('*, users(username)')
        .order('created_at', ascending: false);
    setState(() {
      equipment = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> fetchUsers() async {
    final result = await supabase
        .from('users')
        .select('id, username')
        .order('username');
    setState(() {
      users = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> addEquipment() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => EquipmentDialog(
        users: users,
        onSave: (equipmentData) async {
          try {
            await supabase.from('equipment_tracking').insert({
              'equipment_code': equipmentData['equipment_code'],
              'equipment_name': equipmentData['equipment_name'],
              'category': equipmentData['category'],
              'status': equipmentData['status'],
              'assigned_to': equipmentData['assigned_to'],
              'location': equipmentData['location'],
              'last_maintenance': equipmentData['last_maintenance'],
              'next_maintenance': equipmentData['next_maintenance'],
              'notes': equipmentData['notes'],
            });
            Navigator.pop(context);
            await fetchEquipment();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ekipman eklendi')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Hata: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }

  Future<void> updateEquipmentStatus(String equipmentId, String newStatus) async {
    try {
      await supabase
          .from('equipment_tracking')
          .update({'status': newStatus})
          .eq('id', equipmentId);
      await fetchEquipment();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ekipman durumu güncellendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredEquipment {
    if (searchQuery.isEmpty) return equipment;
    return equipment.where((item) {
      final name = item['equipment_name']?.toString().toLowerCase() ?? '';
      final code = item['equipment_code']?.toString().toLowerCase() ?? '';
      final category = item['category']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query) || category.contains(query);
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'in_use':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'out_of_service':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'Müsait';
      case 'in_use':
        return 'Kullanımda';
      case 'maintenance':
        return 'Bakımda';
      case 'out_of_service':
        return 'Servis Dışı';
      default:
        return 'Bilinmiyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 12);

    return Scaffold(
      appBar: AppBar(
        title: Text("Ekipman Takibi", style: TextStyle(fontSize: titleFont)),
        backgroundColor: Color(0xFF186bfd),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: addEquipment,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchData,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: labelFont)))
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
                hintText: 'Ekipman ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

            // Ekipman Özeti
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF186bfd).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.build, color: Color(0xFF186bfd)),
                  SizedBox(width: 8),
                  Text(
                    '${filteredEquipment.length} ekipman bulundu',
                    style: TextStyle(
                      fontSize: labelFont,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF186bfd),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

            // Ekipman Listesi
            Expanded(
              child: filteredEquipment.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.build_circle, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      searchQuery.isEmpty
                          ? 'Henüz ekipman bulunmuyor'
                          : 'Arama sonucu bulunamadı',
                      style: TextStyle(fontSize: labelFont, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredEquipment.length,
                itemBuilder: (context, index) {
                  final item = filteredEquipment[index];
                  final assignedUser = item['users'] ?? {};
                  final statusColor = _getStatusColor(item['status']);

                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.build,
                          color: statusColor,
                        ),
                      ),
                      title: Text(
                        item['equipment_name'] ?? 'Ekipman',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kod: ${item['equipment_code'] ?? 'N/A'}"),
                          Text("Kategori: ${item['category'] ?? 'N/A'}"),
                          Text("Konum: ${item['location'] ?? 'N/A'}"),
                          if (assignedUser['username'] != null)
                            Text("Atanan: ${assignedUser['username']}"),
                          Row(
                            children: [
                              Text("Durum: "),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(item['status']),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'update_status') {
                            _showUpdateStatusDialog(item);
                          } else if (value == 'details') {
                            _showEquipmentDetails(item);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'update_status',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Durum Güncelle'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.info, size: 16),
                                SizedBox(width: 8),
                                Text('Detaylar'),
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

  void _showUpdateStatusDialog(Map<String, dynamic> equipment) {
    String selectedStatus = equipment['status'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Durum Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${equipment['equipment_name']}'),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: 'Yeni Durum',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'available', child: Text('Müsait')),
                DropdownMenuItem(value: 'in_use', child: Text('Kullanımda')),
                DropdownMenuItem(value: 'maintenance', child: Text('Bakımda')),
                DropdownMenuItem(value: 'out_of_service', child: Text('Servis Dışı')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
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
            onPressed: () {
              updateEquipmentStatus(equipment['id'], selectedStatus);
              Navigator.pop(context);
            },
            child: Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showEquipmentDetails(Map<String, dynamic> equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ekipman Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kod: ${equipment['equipment_code']}'),
            Text('Ad: ${equipment['equipment_name']}'),
            Text('Kategori: ${equipment['category'] ?? 'N/A'}'),
            Text('Durum: ${_getStatusText(equipment['status'])}'),
            Text('Konum: ${equipment['location'] ?? 'N/A'}'),
            if (equipment['last_maintenance'] != null)
              Text('Son Bakım: ${equipment['last_maintenance']}'),
            if (equipment['next_maintenance'] != null)
              Text('Sonraki Bakım: ${equipment['next_maintenance']}'),
            if (equipment['notes'] != null && equipment['notes'].isNotEmpty)
              Text('Notlar: ${equipment['notes']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }
}

class EquipmentDialog extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function(Map<String, dynamic>) onSave;

  EquipmentDialog({required this.users, required this.onSave});

  @override
  _EquipmentDialogState createState() => _EquipmentDialogState();
}

class _EquipmentDialogState extends State<EquipmentDialog> {
  final TextEditingController equipmentCodeController = TextEditingController();
  final TextEditingController equipmentNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController lastMaintenanceController = TextEditingController();
  final TextEditingController nextMaintenanceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String selectedStatus = 'available';
  String? selectedAssignedTo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Yeni Ekipman'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: equipmentCodeController,
              decoration: InputDecoration(
                labelText: 'Ekipman Kodu *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: equipmentNameController,
              decoration: InputDecoration(
                labelText: 'Ekipman Adı *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: 'Durum',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'available', child: Text('Müsait')),
                DropdownMenuItem(value: 'in_use', child: Text('Kullanımda')),
                DropdownMenuItem(value: 'maintenance', child: Text('Bakımda')),
                DropdownMenuItem(value: 'out_of_service', child: Text('Servis Dışı')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedAssignedTo,
              decoration: InputDecoration(
                labelText: 'Atanan Kişi',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('Atanmamış')),
                ...widget.users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user['id'],
                    child: Text(user['username'] ?? 'Kullanıcı'),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  selectedAssignedTo = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Konum',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lastMaintenanceController,
              decoration: InputDecoration(
                labelText: 'Son Bakım Tarihi (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nextMaintenanceController,
              decoration: InputDecoration(
                labelText: 'Sonraki Bakım Tarihi (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (equipmentCodeController.text.isNotEmpty &&
                equipmentNameController.text.isNotEmpty) {
              widget.onSave({
                'equipment_code': equipmentCodeController.text,
                'equipment_name': equipmentNameController.text,
                'category': categoryController.text,
                'status': selectedStatus,
                'assigned_to': selectedAssignedTo,
                'location': locationController.text,
                'last_maintenance': lastMaintenanceController.text.isNotEmpty
                    ? lastMaintenanceController.text
                    : null,
                'next_maintenance': nextMaintenanceController.text.isNotEmpty
                    ? nextMaintenanceController.text
                    : null,
                'notes': notesController.text,
              });
            }
          },
          child: Text('Kaydet'),
        ),
      ],
    );
  }
}