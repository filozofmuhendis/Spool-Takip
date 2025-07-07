import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';

class ShippingManagementPage extends StatefulWidget {
  @override
  _ShippingManagementPageState createState() => _ShippingManagementPageState();
}

class _ShippingManagementPageState extends State<ShippingManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> shippingList = [];
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> spools = [];
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

      // Spool'ları yükle
      final spoolsResponse = await supabase
          .from('spools')
          .select()
          .order('spool_number');

      // Sevkiyat listesini yükle
      final shippingResponse = await supabase
          .from('shipping')
          .select('*, projects(name)')
          .order('created_at', ascending: false);

      setState(() {
        projects = List<Map<String, dynamic>>.from(projectsResponse);
        spools = List<Map<String, dynamic>>.from(spoolsResponse);
        shippingList = List<Map<String, dynamic>>.from(shippingResponse);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu: $e';
        loading = false;
      });
    }
  }

  Future<void> _showShippingDialog([Map<String, dynamic>? shipping]) async {
    final isEditing = shipping != null;
    final formKey = GlobalKey<FormState>();

    final shippingNumberController = TextEditingController(text: shipping?['shipping_number'] ?? '');
    final destinationController = TextEditingController(text: shipping?['destination'] ?? '');
    final carrierController = TextEditingController(text: shipping?['carrier'] ?? '');
    final trackingNumberController = TextEditingController(text: shipping?['tracking_number'] ?? '');
    final notesController = TextEditingController(text: shipping?['notes'] ?? '');

    int? selectedProjectId = shipping?['project_id'];
    String status = shipping?['status'] ?? 'pending';
    DateTime? shippingDate = shipping?['shipping_date'] != null ? DateTime.parse(shipping!['shipping_date']) : null;
    DateTime? expectedDeliveryDate = shipping?['expected_delivery_date'] != null ? DateTime.parse(shipping!['expected_delivery_date']) : null;
    DateTime? actualDeliveryDate = shipping?['actual_delivery_date'] != null ? DateTime.parse(shipping!['actual_delivery_date']) : null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Sevkiyat Düzenle' : 'Yeni Sevkiyat Oluştur'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: shippingNumberController,
                  decoration: InputDecoration(
                    labelText: 'Sevkiyat Numarası *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sevkiyat numarası gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedProjectId,
                  decoration: InputDecoration(
                    labelText: 'Proje',
                    border: OutlineInputBorder(),
                  ),
                  items: projects.map((project) {
                    return DropdownMenuItem<int>(
                      value: project['id'],
                      child: Text(project['name']),
                    );
                  }).toList(),
                  onChanged: (value) => selectedProjectId = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    labelText: 'Hedef *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hedef gerekli';
                    }
                    return null;
                  },
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
                          DropdownMenuItem(value: 'in_transit', child: Text('Yolda')),
                          DropdownMenuItem(value: 'delivered', child: Text('Teslim Edildi')),
                          DropdownMenuItem(value: 'cancelled', child: Text('İptal Edildi')),
                        ],
                        onChanged: (value) => status = value!,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: carrierController,
                        decoration: InputDecoration(
                          labelText: 'Kargo Firması',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: trackingNumberController,
                  decoration: InputDecoration(
                    labelText: 'Takip Numarası',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: shippingDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => shippingDate = date);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            shippingDate != null
                                ? 'Sevkiyat: ${shippingDate!.day}/${shippingDate!.month}/${shippingDate!.year}'
                                : 'Sevkiyat Tarihi',
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
                            initialDate: expectedDeliveryDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => expectedDeliveryDate = date);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expectedDeliveryDate != null
                                ? 'Beklenen: ${expectedDeliveryDate!.day}/${expectedDeliveryDate!.month}/${expectedDeliveryDate!.year}'
                                : 'Beklenen Teslim',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: actualDeliveryDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => actualDeliveryDate = date);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      actualDeliveryDate != null
                          ? 'Gerçek Teslim: ${actualDeliveryDate!.day}/${actualDeliveryDate!.month}/${actualDeliveryDate!.year}'
                          : 'Gerçek Teslim Tarihi',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
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
                  final shippingData = {
                    'shipping_number': shippingNumberController.text,
                    'project_id': selectedProjectId,
                    'destination': destinationController.text,
                    'status': status,
                    'carrier': carrierController.text,
                    'tracking_number': trackingNumberController.text,
                    'shipping_date': shippingDate?.toIso8601String().split('T')[0],
                    'expected_delivery_date': expectedDeliveryDate?.toIso8601String().split('T')[0],
                    'actual_delivery_date': actualDeliveryDate?.toIso8601String().split('T')[0],
                    'notes': notesController.text,
                    'created_by': supabase.auth.currentUser!.id,
                  };

                  if (isEditing) {
                    await supabase
                        .from('shipping')
                        .update(shippingData)
                        .eq('id', shipping!['id']);
                  } else {
                    await supabase
                        .from('shipping')
                        .insert(shippingData);
                  }

                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Sevkiyat güncellendi' : 'Sevkiyat oluşturuldu'),
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

  Future<void> _showShippingItemsDialog(Map<String, dynamic> shipping) async {
    List<Map<String, dynamic>> shippingItems = [];
    bool loading = true;

    try {
      final response = await supabase
          .from('shipping_items')
          .select('*, spools(spool_number, title)')
          .eq('shipping_id', shipping['id']);

      shippingItems = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Sevkiyat kalemleri yüklenirken hata: $e');
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Sevkiyat Kalemleri'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (shippingItems.isEmpty)
                  Text('Henüz kalem eklenmemiş')
                else
                  ...shippingItems.map((item) => ListTile(
                    title: Text(item['spools']['spool_number']),
                    subtitle: Text(item['spools']['title'] ?? ''),
                    trailing: Text('Adet: ${item['quantity']}'),
                  )),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _addShippingItem(shipping['id']),
                  child: Text('Kalem Ekle'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kapat'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addShippingItem(int shippingId) async {
    int? selectedSpoolId;
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sevkiyat Kalemi Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: selectedSpoolId,
              decoration: InputDecoration(
                labelText: 'Spool *',
                border: OutlineInputBorder(),
              ),
              items: spools.map((spool) {
                return DropdownMenuItem<int>(
                  value: spool['id'],
                  child: Text('${spool['spool_number']} - ${spool['title'] ?? ''}'),
                );
              }).toList(),
              onChanged: (value) => selectedSpoolId = value,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Adet',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
              ),
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
              if (selectedSpoolId != null) {
                try {
                  await supabase.from('shipping_items').insert({
                    'shipping_id': shippingId,
                    'spool_id': selectedSpoolId,
                    'quantity': int.tryParse(quantityController.text) ?? 1,
                    'notes': notesController.text,
                  });

                  Navigator.pop(context);
                  _showShippingItemsDialog({'id': shippingId});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kalem eklendi'),
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
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteShipping(int shippingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sevkiyat Sil'),
        content: Text('Bu sevkiyatı silmek istediğinizden emin misiniz?'),
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
            .from('shipping')
            .delete()
            .eq('id', shippingId);

        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sevkiyat silindi'),
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
      case 'in_transit':
        return '#2196F3';
      case 'delivered':
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
      case 'in_transit':
        return 'Yolda';
      case 'delivered':
        return 'Teslim Edildi';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sevkiyat Yönetimi'),
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
          : shippingList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Henüz sevkiyat bulunmuyor'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showShippingDialog(),
              child: Text('İlk Sevkiyatı Oluştur'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: shippingList.length,
        itemBuilder: (context, index) {
          final shipping = shippingList[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      shipping['shipping_number'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(int.parse(_getStatusColor(shipping['status']).replaceAll('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(shipping['status']),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text('Hedef: ${shipping['destination']}'),
                  if (shipping['projects'] != null)
                    Text('Proje: ${shipping['projects']['name']}'),
                  if (shipping['carrier'] != null)
                    Text('Kargo: ${shipping['carrier']}'),
                  if (shipping['tracking_number'] != null)
                    Text('Takip No: ${shipping['tracking_number']}'),
                  if (shipping['notes'] != null)
                    Text('Notlar: ${shipping['notes']}'),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'items',
                    child: Row(
                      children: [
                        Icon(Icons.list),
                        SizedBox(width: 8),
                        Text('Kalemler'),
                      ],
                    ),
                  ),
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
                  if (value == 'items') {
                    _showShippingItemsDialog(shipping);
                  } else if (value == 'edit') {
                    _showShippingDialog(shipping);
                  } else if (value == 'delete') {
                    _deleteShipping(shipping['id']);
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showShippingDialog(),
        backgroundColor: Color(0xFF186bfd),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}