import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobOrderTrackingPage extends StatefulWidget {
  final String jobOrderId;
  final String workerId;

  const JobOrderTrackingPage({
    required this.jobOrderId,
    required this.workerId,
    Key? key,
  }) : super(key: key);

  @override
  State<JobOrderTrackingPage> createState() => _JobOrderTrackingPageState();
}

class _JobOrderTrackingPageState extends State<JobOrderTrackingPage> {
  final supabase = Supabase.instance.client;
  bool isAccepted = false;
  bool isFinished = false;
  DateTime? acceptedTime;
  DateTime? finishedTime;
  Timer? timer;
  Duration elapsed = Duration.zero;

  List<Map<String, dynamic>> jobHistory = [];

  @override
  void initState() {
    super.initState();
    loadExistingJob();
    loadJobHistory();
  }

  Future<void> loadExistingJob() async {
    final result = await supabase
        .from('job_orders_tracking')
        .select()
        .eq('job_order_id', widget.jobOrderId)
        .eq('worker_id', widget.workerId)
        .maybeSingle();

    if (result != null) {
      setState(() {
        isAccepted = result['status'] != 'bekliyor';
        isFinished = result['status'] == 'tamamlandı';
        if (result['accepted_at'] != null) {
          acceptedTime = DateTime.parse(result['accepted_at']);
          if (!isFinished) startTimer();
        }
        if (result['finished_at'] != null) {
          finishedTime = DateTime.parse(result['finished_at']);
          elapsed = Duration(minutes: result['duration_minutes'] ?? 0);
        }
      });
    }
  }

  Future<void> loadJobHistory() async {
    final result = await supabase
        .from('job_orders_tracking')
        .select()
        .eq('worker_id', widget.workerId)
        .order('accepted_at', ascending: false);

    setState(() {
      jobHistory = List<Map<String, dynamic>>.from(result);
    });
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (acceptedTime != null) {
        final now = DateTime.now();
        setState(() {
          elapsed = now.difference(acceptedTime!);
        });
      }
    });
  }

  Future<void> acceptJob() async {
    acceptedTime = DateTime.now();
    await supabase.from('job_orders_tracking').insert({
      'job_order_id': widget.jobOrderId,
      'worker_id': widget.workerId,
      'accepted_at': acceptedTime!.toIso8601String(),
      'status': 'kabul',
    });
    startTimer();
    setState(() {
      isAccepted = true;
    });
  }

  Future<void> finishJob() async {
    if (acceptedTime == null) return;
    finishedTime = DateTime.now();
    final duration = finishedTime!.difference(acceptedTime!).inMinutes;

    await supabase
        .from('job_orders_tracking')
        .update({
      'finished_at': finishedTime!.toIso8601String(),
      'duration_minutes': duration,
      'status': 'tamamlandı',
    })
        .eq('job_order_id', widget.jobOrderId)
        .eq('worker_id', widget.workerId);

    timer?.cancel();
    setState(() {
      isFinished = true;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    return '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İş Emri Süre Takibi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('İş Emri ID: ${widget.jobOrderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (acceptedTime != null)
                Text('Kabul Zamanı: $acceptedTime'),
              if (finishedTime != null)
                Text('Bitiş Zamanı: $finishedTime'),
              const SizedBox(height: 10),
              if (isAccepted && !isFinished)
                Text('Geçen Süre: ${formatDuration(elapsed)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isAccepted ? null : acceptJob,
                child: const Text('İşi Kabul Et'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: (!isAccepted || isFinished) ? null : finishJob,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('İşi Bitir'),
              ),
              const Divider(height: 30),
              const Text('Önceki İş Emri Geçmişi:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...jobHistory.map((job) {
                final accepted = job['accepted_at'] != null ? DateTime.parse(job['accepted_at']).toLocal().toString() : '-';
                final duration = job['duration_minutes'] ?? 0;
                final status = job['status'];
                return ListTile(
                  title: Text('İş Emri: ${job['job_order_id']}'),
                  subtitle: Text('Durum: $status\nKabul: $accepted\nSüre: $duration dk'),
                  dense: true,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
