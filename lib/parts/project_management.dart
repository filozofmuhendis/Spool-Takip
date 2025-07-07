import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:spool/parts/error_page.dart';

class ProjectManagementPage extends StatefulWidget {
  @override
  _ProjectManagementPageState createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> projects = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final response = await supabase
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        projects = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Projeler yüklenirken hata oluştu: $e';
        loading = false;
      });
    }
  }

  Future<void> _showProjectDialog([Map<String, dynamic>? project]) async {
    final isEditing = project != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: project?['name'] ?? '');
    final descriptionController = TextEditingController(text: project?['description'] ?? '');
    final clientNameController = TextEditingController(text: project?['client_name'] ?? '');
    final projectCodeController = TextEditingController(text: project?['project_code'] ?? '');

    String status = project?['status'] ?? 'active';
    String priority = project?['priority'] ?? 'medium';
    DateTime? startDate = project?['start_date'] != null ? DateTime.parse(project!['start_date']) : null;
    DateTime? endDate = project?['end_date'] != null ? DateTime.parse(project!['end_date']) : null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Proje Düzenle' : 'Yeni Proje Oluştur'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Proje Adı *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proje adı gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: projectCodeController,
                  decoration: InputDecoration(
                    labelText: 'Proje Kodu *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proje kodu gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: clientNameController,
                  decoration: InputDecoration(
                    labelText: 'Müşteri Adı',
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
                          DropdownMenuItem(value: 'active', child: Text('Aktif')),
                          DropdownMenuItem(value: 'completed', child: Text('Tamamlandı')),
                          DropdownMenuItem(value: 'paused', child: Text('Duraklatıldı')),
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
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => endDate = date);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            endDate != null
                                ? 'Bitiş: ${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                : 'Bitiş Tarihi',
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  final projectData = {
                    'name': nameController.text,
                    'project_code': projectCodeController.text,
                    'client_name': clientNameController.text,
                    'description': descriptionController.text,
                    'status': status,
                    'priority': priority,
                    'start_date': startDate?.toIso8601String().split('T')[0],
                    'end_date': endDate?.toIso8601String().split('T')[0],
                    'created_by': supabase.auth.currentUser!.id,
                  };

                  if (isEditing) {
                    await supabase
                        .from('projects')
                        .update(projectData)
                        .eq('id', project!['id']);
                  } else {
                    await supabase
                        .from('projects')
                        .insert(projectData);
                  }

                  Navigator.pop(context);
                  _loadProjects();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Proje güncellendi' : 'Proje oluşturuldu'),
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

  Future<void> _deleteProject(int projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Proje Sil'),
        content: Text('Bu projeyi silmek istediğinizden emin misiniz?'),
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
            .from('projects')
            .delete()
            .eq('id', projectId);

        _loadProjects();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Proje silindi'),
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
      case 'active':
        return '#4CAF50';
      case 'completed':
        return '#2196F3';
      case 'paused':
        return '#FF9800';
      case 'cancelled':
        return '#F44336';
      default:
        return '#757575';
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
        title: Text('Projeler', style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20))),
        backgroundColor: const Color(0xFF186bfd),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? ErrorPage(
                  message: errorMessage!,
                  errorType: ErrorType.data,
                  onRetry: _loadProjects,
                )
              : Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
                  child: Column(
                    children: [
                      projects.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('Henüz proje bulunmuyor'),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _showProjectDialog(),
                                    child: Text('İlk Projeyi Oluştur'),
                                  ),
                                ],
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: projects.length,
                                itemBuilder: (context, index) {
                                  final project = projects[index];
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 16),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              project['name'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(_getStatusColor(project['status']).replaceAll('#', '0xFF'))),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              project['status'] == 'active' ? 'Aktif' :
                                              project['status'] == 'completed' ? 'Tamamlandı' :
                                              project['status'] == 'paused' ? 'Duraklatıldı' : 'İptal',
                                              style: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          if (project['project_code'] != null)
                                            Text('Kod: ${project['project_code']}'),
                                          if (project['client_name'] != null)
                                            Text('Müşteri: ${project['client_name']}'),
                                          if (project['description'] != null)
                                            Text('Açıklama: ${project['description']}'),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.priority_high, size: 16),
                                              SizedBox(width: 4),
                                              Text(_getPriorityText(project['priority'])),
                                              Spacer(),
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
                                            _showProjectDialog(project);
                                          } else if (value == 'delete') {
                                            _deleteProject(project['id']);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProjectDialog(),
        backgroundColor: Color(0xFF186bfd),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}