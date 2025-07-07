import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionPlanningPage extends StatefulWidget {
  @override
  _ProductionPlanningPageState createState() => _ProductionPlanningPageState();
}

class _ProductionPlanningPageState extends State<ProductionPlanningPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> productionPlans = [];
  List<Map<String, dynamic>> projects = [];
  bool loading = true;
  String? errorMessage;

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
        fetchProductionPlans(),
        fetchProjects(),
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

  Future<void> fetchProductionPlans() async {
    final result = await supabase
        .from('production_planning')
        .select('*, projects(name)')
        .order('created_at', ascending: false);
    setState(() {
      productionPlans = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> fetchProjects() async {
    final result = await supabase
        .from('projects')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false);
    setState(() {
      projects = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> addProductionPlan() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => ProductionPlanDialog(
        projects: projects,
        onSave: (planData) async {
          try {
            await supabase.from('production_planning').insert({
              'project_id': planData['project_id'],
              'plan_name': planData['plan_name'],
              'start_date': planData['start_date'],
              'end_date': planData['end_date'],
              'priority': planData['priority'],
              'assigned_team': planData['assigned_team'],
              'created_by': user.id,
            });
            Navigator.pop(context);
            await fetchProductionPlans();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Üretim planı eklendi')),
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'delayed':
        return Colors.red;
      case 'planned':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'urgent':
        return 'Acil';
      case 'high':
        return 'Yüksek';
      case 'medium':
        return 'Orta';
      case 'low':
        return 'Düşük';
      default:
        return 'Bilinmiyor';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Tamamlandı';
      case 'in_progress':
        return 'İşlemde';
      case 'delayed':
        return 'Gecikti';
      case 'planned':
        return 'Planlandı';
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
        title: Text("Üretim Planlama", style: TextStyle(fontSize: titleFont)),
        backgroundColor: Color(0xFF186bfd),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: addProductionPlan,
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
            : productionPlans.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Henüz üretim planı bulunmuyor',
                style: TextStyle(fontSize: labelFont, color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: addProductionPlan,
                child: Text('İlk Planı Oluştur'),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: productionPlans.length,
          itemBuilder: (context, index) {
            final plan = productionPlans[index];
            final project = plan['projects'] ?? {};

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan['plan_name'] ?? 'Plan',
                            style: TextStyle(
                              fontSize: titleFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(plan['priority']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getPriorityText(plan['priority']),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPriorityColor(plan['priority']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Proje: ${project['name'] ?? 'N/A'}",
                      style: TextStyle(fontSize: labelFont),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "${plan['start_date'] ?? 'N/A'} - ${plan['end_date'] ?? 'N/A'}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(plan['status']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(plan['status']),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(plan['status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        if (plan['assigned_team'] != null && (plan['assigned_team'] as List).isNotEmpty)
                          Text(
                            "Ekip: ${(plan['assigned_team'] as List).join(', ')}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProductionPlanDialog extends StatefulWidget {
  final List<Map<String, dynamic>> projects;
  final Function(Map<String, dynamic>) onSave;

  ProductionPlanDialog({required this.projects, required this.onSave});

  @override
  _ProductionPlanDialogState createState() => _ProductionPlanDialogState();
}

class _ProductionPlanDialogState extends State<ProductionPlanDialog> {
  final TextEditingController planNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController teamController = TextEditingController();
  int? selectedProjectId;
  String selectedPriority = 'medium';
  String selectedStatus = 'planned';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Yeni Üretim Planı'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: planNameController,
              decoration: InputDecoration(
                labelText: 'Plan Adı *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedProjectId,
              decoration: InputDecoration(
                labelText: 'Proje *',
                border: OutlineInputBorder(),
              ),
              items: widget.projects.map((project) {
                return DropdownMenuItem<int>(
                  value: project['id'],
                  child: Text(project['name'] ?? 'Proje'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProjectId = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: startDateController,
              decoration: InputDecoration(
                labelText: 'Başlangıç Tarihi (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: endDateController,
              decoration: InputDecoration(
                labelText: 'Bitiş Tarihi (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedPriority,
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
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: teamController,
              decoration: InputDecoration(
                labelText: 'Atanan Ekip (virgülle ayırın)',
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
            if (planNameController.text.isNotEmpty && selectedProjectId != null) {
              widget.onSave({
                'plan_name': planNameController.text,
                'project_id': selectedProjectId,
                'start_date': startDateController.text,
                'end_date': endDateController.text,
                'priority': selectedPriority,
                'assigned_team': teamController.text.isNotEmpty
                    ? teamController.text.split(',').map((e) => e.trim()).toList()
                    : [],
              });
            }
          },
          child: Text('Kaydet'),
        ),
      ],
    );
  }
}