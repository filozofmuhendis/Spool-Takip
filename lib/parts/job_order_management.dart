import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';

class JobOrderManagementPage extends StatefulWidget {
  @override
  _JobOrderManagementPageState createState() => _JobOrderManagementPageState();
}

class _JobOrderManagementPageState extends State<JobOrderManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> jobOrders = [];
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // Projeleri yükle
      final projectsResponse = await supabase
          .from('projects')
          .select()
          .order('name');

      // Kullanıcıları yükle
      final usersResponse = await supabase
          .from('users')
          .select()
          .order('username');

      // İş emirlerini yükle
      final jobOrdersResponse = await supabase
          .from('job_orders')
          .select('*, projects(name), users!job_orders_assigned_to_fkey(username)')
          .order('created_at', ascending: false);

      setState(() {
        projects = List<Map<String, dynamic>>.from(projectsResponse);
        users = List<Map<String, dynamic>>.from(usersResponse);
        jobOrders = List<Map<String, dynamic>>.from(jobOrdersResponse);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu: $e';
        loading = false;
      });
    }
  }

  Future<void> _showJobOrderDialog([Map<String, dynamic>? jobOrder]) async {
    final isEditing = jobOrder != null;
    final formKey = GlobalKey<FormState>();

    final jobOrderNumberController = TextEditingController(text: jobOrder?['job_order_number'] ?? '');
    final titleController = TextEditingController(text: jobOrder?['title'] ?? '');
    final descriptionController = TextEditingController(text: jobOrder?['description'] ?? '');
    final estimatedHoursController = TextEditingController(text: jobOrder?['estimated_hours']?.toString() ?? '');
    final notesController = TextEditingController(text: jobOrder?['notes'] ?? '');

    int? selectedProjectId = jobOrder?['project_id'];
    String? selectedUserId = jobOrder?['assigned_to'];
    String status = jobOrder?['status'] ?? 'pending';
    String priority = jobOrder?['priority'] ?? 'medium';
    DateTime? startDate = jobOrder?['start_date'] != null ? DateTime.parse(jobOrder!['start_date']) : null;
    DateTime? dueDate = jobOrder?['due_date'] != null ? DateTime.parse(jobOrder!['due_date']) : null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'İş Emri Düzenle' : 'Yeni İş Emri Oluştur'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: jobOrderNumberController,
                  decoration: InputDecoration(
                    labelText: 'İş Emri Numarası *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İş emri numarası gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Başlık *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Başlık gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedProjectId,
                  decoration: InputDecoration(
                    labelText: 'Proje *',
                    border: OutlineInputBorder(),
                  ),
                  items: projects.map((project) {
                    return DropdownMenuItem<int>(
                      value: project['id'],
                      child: Text(project['name']),
                    );
                  }).toList(),
                  onChanged: (value) => selectedProjectId = value,
                  validator: (value) {
                    if (value == null) {
                      return 'Proje seçimi gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedUserId,
                  decoration: InputDecoration(
                    labelText: 'Atanan Kişi',
                    border: OutlineInputBorder(),
                  ),
                  items: users.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['id'],
                      child: Text(user['username'] ?? user['email']),
                    );
                  }).toList(),
                  onChanged: (value) => selectedUserId = value,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: status,
                        decoration: InputDecoration(
                          labelText: 'Durum',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'pending', child: Text('Bekliyor')),
                          DropdownMenuItem(value: 'assigned', child: Text('Atandı')),
                          DropdownMenuItem(value: 'in_progress', child: Text('Devam Ediyor')),
                          DropdownMenuItem(value: 'completed', child: Text('Tamamlandı')),
                          DropdownMenuItem(value: 'cancelled', child: Text('İptal Edildi')),
                        ],
                        onChanged: (value) => status = value!,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: priority,
                        decoration: InputDecoration(
                          labelText: 'Öncelik',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'low', child: Text('Düşük')),
                          DropdownMenuItem(value: 'medium', child: Text('Orta')),
                          DropdownMenuItem(value: 'high', child: Text('Yüksek')),
                          DropdownMenuItem(value: 'urgent', child: Text('Acil')),
                        ],
                        onChanged: (value) => priority = value!,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => startDate = date);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            startDate != null
                                ? 'Başlangıç: ${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                : 'Başlangıç Tarihi',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => dueDate = date);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            dueDate != null
                                ? 'Teslim: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                                : 'Teslim Tarihi',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: estimatedHoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Tahmini Süre (Saat)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notlar',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final jobOrderData = {
                    'job_order_number': jobOrderNumberController.text,
                    'title': titleController.text,
                    'project_id': selectedProjectId,
                    'assigned_to': selectedUserId,
                    'status': status,
                    'priority': priority,
                    'start_date': startDate?.toIso8601String().split('T')[0],
                    'due_date': dueDate?.toIso8601String().split('T')[0],
                    'estimated_hours': estimatedHoursController.text.isNotEmpty ? int.tryParse(estimatedHoursController.text) : null,
                    'description': descriptionController.text,
                    'notes': notesController.text,
                    'created_by': supabase.auth.currentUser!.id,
                  };

                  if (isEditing) {
                    await supabase
                        .from('job_orders')
                        .update(jobOrderData)
                        .eq('id', jobOrder!['id']);
                  } else {
                    await supabase
                        .from('job_orders')
                        .insert(jobOrderData);
                  }

                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'İş emri güncellendi' : 'İş emri oluşturuldu'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Güncelle' : 'Oluştur'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteJobOrder(int jobOrderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İş Emri Sil'),
        content: Text('Bu iş emrini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase
            .from('job_orders')
            .delete()
            .eq('id', jobOrderId);

        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İş emri silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return '#FF9800';
      case 'assigned':
        return '#2196F3';
      case 'in_progress':
        return '#4CAF50';
      case 'completed':
        return '#4CAF50';
      case 'cancelled':
        return '#F44336';
      default:
        return '#757575';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Bekliyor';
      case 'assigned':
        return 'Atandı';
      case 'in_progress':
        return 'Devam Ediyor';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal';
      default:
        return status;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'Düşük';
      case 'medium':
        return 'Orta';
      case 'high':
        return 'Yüksek';
      case 'urgent':
        return 'Acil';
      default:
        return 'Orta';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İş Emri Yönetimi'),
        backgroundColor: Color(0xFF186bfd),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(errorMessage!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Tekrar Dene'),
            ),
          ],
        ),
      )
          : jobOrders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Henüz iş emri bulunmuyor'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showJobOrderDialog(),
              child: Text('İlk İş Emrini Oluştur'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: jobOrders.length,
        itemBuilder: (context, index) {
          final jobOrder = jobOrders[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      jobOrder['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(int.parse(_getStatusColor(jobOrder['status']).replaceAll('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(jobOrder['status']),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text('İş Emri No: ${jobOrder['job_order_number']}'),
                  if (jobOrder['projects'] != null)
                    Text('Proje: ${jobOrder['projects']['name']}'),
                  if (jobOrder['users'] != null)
                    Text('Atanan: ${jobOrder['users']['username']}'),
                  if (jobOrder['description'] != null)
                    Text('Açıklama: ${jobOrder['description']}'),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.priority_high, size: 16),
                      SizedBox(width: 4),
                      Text(_getPriorityText(jobOrder['priority'])),
                      Spacer(),
                      if (jobOrder['estimated_hours'] != null)
                        Text('${jobOrder['estimated_hours']} saat'),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showJobOrderDialog(jobOrder);
                  } else if (value == 'delete') {
                    _deleteJobOrder(jobOrder['id']);
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJobOrderDialog(),
        backgroundColor: Color(0xFF186bfd),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}