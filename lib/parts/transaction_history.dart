import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Kullanıcı oturumu bulunamadı.';
          loading = false;
        });
        return;
      }
      final result = await Supabase.instance.client
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      setState(() {
        transactions = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'İşlem geçmişi yüklenirken hata oluştu:\n${e.toString()}';
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
    double buttonFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double buttonPadding = ResponsiveHelper.getResponsiveHeight(context, 16);
    double appBarFont = ResponsiveHelper.getResponsiveFontSize(context, 20);

    return Scaffold(
      appBar: AppBar(
        title: Text("İşlem Geçmişi", style: TextStyle(fontSize: appBarFont)),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: titleFont)))
                : transactions.isEmpty
                    ? Center(child: Text('Hiç işlem geçmişiniz yok.', style: TextStyle(fontSize: titleFont)))
                    : RefreshIndicator(
                        onRefresh: fetchTransactions,
                        child: ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(cardRadius),
                              ),
                              elevation: 5,
                              margin: EdgeInsets.only(bottom: padding),
                              child: ListTile(
                                title: Text(transaction['spoolName'] ?? '-', style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  "Tarih: ${transaction['created_at']?.toString().substring(0, 10) ?? '-'}\nDurum: ${transaction['status'] ?? '-'}\nAğırlık: ${transaction['weight'] ?? '-'} kg",
                                  style: TextStyle(fontSize: subtitleFont),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF186bfd), size: ResponsiveHelper.getResponsiveWidth(context, 20)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionDetailsPage(transaction: transaction),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  TransactionDetailsPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transaction['spoolName'] ?? '-'),
        backgroundColor: Color(0xFF186bfd),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("İşlem Detayları", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Spool Adı: ${transaction['spoolName'] ?? '-'}"),
            Text("Durum: ${transaction['status'] ?? '-'}"),
            Text("Tarih: ${transaction['created_at']?.toString().substring(0, 10) ?? '-'}"),
            Text("Ağırlık: ${transaction['weight'] ?? '-'} kg"),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: Text("Daha Fazla Detay"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF186bfd),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}