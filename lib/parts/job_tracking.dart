import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:spool/parts/error_page.dart';

class JobTrackingPage extends StatefulWidget {
  @override
  _JobTrackingPageState createState() => _JobTrackingPageState();
}

class _JobTrackingPageState extends State<JobTrackingPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> assignedJobs = [];
  List<Map<String, dynamic>> trackingRecords = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssignedJobs();
  }

  Future<void> _loadAssignedJobs() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          errorMessage = 'Kullanıcı oturumu bulunamadı';
          loading = false;
        });
        return;
      }

      // Kullanıcıya atanan iş emirlerini yükle
      final response = await supabase
          .from('job_orders')
          .select('*, projects(name)')
          .eq('assigned_to', currentUser.id)
          .inFilter('status', ['assigned', 'in_progress'])
          .order('priority', ascending: false);

      setState(() {
        assignedJobs = List<Map<String, dynamic>>.from(response);
        loading = false;
      });

      // Takip kayıtlarını da yükle
      _loadTrackingRecords();
    } catch (e) {
      setState(() {
        errorMessage = 'İş emirleri yüklenirken hata oluştu: $e';
        loading = false;
      });
    }
  }

  Future<void> _loadTrackingRecords() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      final response = await supabase
          .from('job_order_tracking')
          .select('*, job_orders(title, job_order_number)')
          .eq('worker_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(10);

      setState(() {
        trackingRecords = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Takip kayıtları yüklenirken hata: $e');
    }
  }

  Future<void> _startJob(Map<String, dynamic> jobOrder) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      // Takip kaydı oluştur
      await supabase.from('job_order_tracking').insert({
        'job_order_id': jobOrder['id'],
        'worker_id': currentUser.id,
        'action_type': 'start',
        'start_time': DateTime.now().toIso8601String(),
        'notes': 'İş başlatıldı',
      });

      // İş emri durumunu güncelle
      await supabase
          .from('job_orders')
          .update({'status': 'in_progress'})
          .eq('id', jobOrder['id']);

      _loadAssignedJobs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İş başlatıldı'),
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

  Future<void> _pauseJob(Map<String, dynamic> jobOrder) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      // Takip kaydı oluştur
      await supabase.from('job_order_tracking').insert({
        'job_order_id': jobOrder['id'],
        'worker_id': currentUser.id,
        'action_type': 'pause',
        'start_time': DateTime.now().toIso8601String(),
        'notes': 'İş duraklatıldı',
      });

      _loadAssignedJobs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İş duraklatıldı'),
          backgroundColor: Colors.orange,
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

  Future<void> _completeJob(Map<String, dynamic> jobOrder) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İşi Tamamla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bu işi tamamlamak istediğinizden emin misiniz?'),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Tamamlama Notları',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Tamamla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final currentUser = supabase.auth.currentUser;
        if (currentUser == null) return;

        // Takip kaydı oluştur
        await supabase.from('job_order_tracking').insert({
          'job_order_id': jobOrder['id'],
          'worker_id': currentUser.id,
          'action_type': 'complete',
          'start_time': DateTime.now().toIso8601String(),
          'end_time': DateTime.now().toIso8601String(),
          'notes': notesController.text.isNotEmpty ? notesController.text : 'İş tamamlandı',
        });

        // İş emri durumunu güncelle
        await supabase
            .from('job_orders')
            .update({
          'status': 'completed',
          'completed_date': DateTime.now().toIso8601String().split('T')[0],
        })
            .eq('id', jobOrder['id']);

        _loadAssignedJobs();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İş tamamlandı'),
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
      case 'assigned':
        return '#2196F3';
      case 'in_progress':
        return '#4CAF50';
      default:
        return '#757575';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'assigned':
        return 'Atandı';
      case 'in_progress':
        return 'Devam Ediyor';
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

  String _getActionText(String actionType) {
    switch (actionType) {
      case 'start':
        return 'Başlatıldı';
      case 'pause':
        return 'Duraklatıldı';
      case 'resume':
        return 'Devam Ediyor';
      case 'complete':
        return 'Tamamlandı';
      case 'cancel':
        return 'İptal Edildi';
      default:
        return actionType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('İş Takibi'),
          backgroundColor: Color(0xFF186bfd),
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Atanan İşler'),
              Tab(text: 'Takip Kayıtları'),
            ],
            indicatorColor: Colors.white,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadAssignedJobs,
            ),
          ],
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? ErrorPage(
                    message: errorMessage!,
                    errorType: ErrorType.data,
                    onRetry: _loadAssignedJobs,
                  )
                : TabBarView(
          children: [
            // Atanan İşler Tab
            assignedJobs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Atanan iş bulunmuyor'),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: assignedJobs.length,
              itemBuilder: (context, index) {
                final job = assignedJobs[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            job['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(int.parse(_getStatusColor(job['status']).replaceAll('#', '0xFF'))),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(job['status']),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text('İş Emri No: ${job['job_order_number']}'),
                        if (job['projects'] != null)
                          Text('Proje: ${job['projects']['name']}'),
                        if (job['description'] != null)
                          Text('Açıklama: ${job['description']}'),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.priority_high, size: 16),
                            SizedBox(width: 4),
                            Text(_getPriorityText(job['priority'])),
                            Spacer(),
                            if (job['estimated_hours'] != null)
                              Text('${job['estimated_hours']} saat'),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) {
                        final actions = <PopupMenuItem>[];

                        if (job['status'] == 'assigned') {
                          actions.add(PopupMenuItem(
                            value: 'start',
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Başlat'),
                              ],
                            ),
                          ));
                        } else if (job['status'] == 'in_progress') {
                          actions.add(PopupMenuItem(
                            value: 'pause',
                            child: Row(
                              children: [
                                Icon(Icons.pause, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Duraklat'),
                              ],
                            ),
                          ));
                          actions.add(PopupMenuItem(
                            value: 'complete',
                            child: Row(
                              children: [
                                Icon(Icons.check, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Tamamla'),
                              ],
                            ),
                          ));
                        }

                        return actions;
                      },
                      onSelected: (value) {
                        if (value == 'start') {
                          _startJob(job);
                        } else if (value == 'pause') {
                          _pauseJob(job);
                        } else if (value == 'complete') {
                          _completeJob(job);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            // Takip Kayıtları Tab
            trackingRecords.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Takip kaydı bulunmuyor'),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: trackingRecords.length,
              itemBuilder: (context, index) {
                final record = trackingRecords[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: record['action_type'] == 'complete'
                          ? Colors.green
                          : record['action_type'] == 'pause'
                          ? Colors.orange
                          : Colors.blue,
                      child: Icon(
                        record['action_type'] == 'complete'
                            ? Icons.check
                            : record['action_type'] == 'pause'
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      record['job_orders']['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('İşlem: ${_getActionText(record['action_type'])}'),
                        Text('Tarih: ${DateTime.parse(record['created_at']).toString().substring(0, 16)}'),
                        if (record['notes'] != null)
                          Text('Not: ${record['notes']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}