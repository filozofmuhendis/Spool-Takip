import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'job_order_tracking.dart';
import 'package:spool/parts/responsive_helper.dart';

class JobOrderListPage extends StatefulWidget {
  final String workerId;

  const JobOrderListPage({required this.workerId, Key? key}) : super(key: key);

  @override
  State<JobOrderListPage> createState() => _JobOrderListPageState();
}

class _JobOrderListPageState extends State<JobOrderListPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> jobOrders = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchJobOrders();
  }

  Future<void> fetchJobOrders() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final result = await supabase
          .from('job_orders')
          .select()
          .eq('assigned_worker_id', widget.workerId)
          .neq('status', 'tamamlandı')
          .order('created_at');
      setState(() {
        jobOrders = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'İş emirleri yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 15);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 18);
    double subtitleFont = ResponsiveHelper.getResponsiveFontSize(context, 14);
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 14);
    double appBarFont = ResponsiveHelper.getResponsiveFontSize(context, 20);

    return Scaffold(
      appBar: AppBar(title: Text('Atanmış İş Emirleri', style: TextStyle(fontSize: appBarFont))),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: titleFont)))
                : jobOrders.isEmpty
                    ? Center(child: Text('Hiç atanmış iş emriniz yok.', style: TextStyle(fontSize: titleFont)))
                    : RefreshIndicator(
                        onRefresh: fetchJobOrders,
                        child: ListView.builder(
                          itemCount: jobOrders.length,
                          itemBuilder: (context, index) {
                            final job = jobOrders[index];
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
                              child: ListTile(
                                title: Text(job['title'] ?? 'İsimsiz İş Emri', style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold)),
                                subtitle: Text(job['description'] ?? '', style: TextStyle(fontSize: subtitleFont)),
                                trailing: ElevatedButton(
                                  child: Text('Detay', style: TextStyle(fontSize: buttonFont)),
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
                      ),
      ),
    );
  }
}
