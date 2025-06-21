import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'job_order_tracking.dart';

class JobOrderListPage extends StatefulWidget {
  final String workerId;

  const JobOrderListPage({required this.workerId, Key? key}) : super(key: key);

  @override
  State<JobOrderListPage> createState() => _JobOrderListPageState();
}

class _JobOrderListPageState extends State<JobOrderListPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> jobOrders = [];

  @override
  void initState() {
    super.initState();
    fetchJobOrders();
  }

  Future<void> fetchJobOrders() async {
    final result = await supabase
        .from('job_orders')
        .select()
        .eq('assigned_worker_id', widget.workerId)
        .neq('status', 'tamamlandı')
        .order('created_at');

    setState(() {
      jobOrders = List<Map<String, dynamic>>.from(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atanmış İş Emirleri')),
      body: ListView.builder(
        itemCount: jobOrders.length,
        itemBuilder: (context, index) {
          final job = jobOrders[index];
          return Card(
            child: ListTile(
              title: Text(job['title'] ?? 'İsimsiz İş Emri'),
              subtitle: Text(job['description'] ?? ''),
              trailing: ElevatedButton(
                child: const Text('Detay'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobOrderTrackingPage(
                        jobOrderId: job['id'],
                        workerId: widget.workerId,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
