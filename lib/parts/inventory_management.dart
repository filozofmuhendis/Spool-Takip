import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:spool/parts/error_page.dart';

class InventoryManagementPage extends StatefulWidget {
  @override
  _InventoryManagementPageState createState() => _InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> inventory = [];
  List<Map<String, dynamic>> transactions = [];
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
      // Stok listesini yükle
      final inventoryResponse = await supabase
          .from('inventory')
          .select()
          .order('material_name');

      // Son işlemleri yükle
      final transactionsResponse = await supabase
          .from('inventory_transactions')
          .select('*, inventory(material_name, material_code)')
          .order('created_at', ascending: false)
          .limit(20);

      setState(() {
        inventory = List<Map<String, dynamic>>.from(inventoryResponse);
        transactions = List<Map<String, dynamic>>.from(transactionsResponse);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu: $e';
        loading = false;
      });
    }
  }

  Future<void> _showInventoryDialog([Map<String, dynamic>? item]) async {
    final isEditing = item != null;
    final formKey = GlobalKey<FormState>();

    final materialCodeController = TextEditingController(text: item?['material_code'] ?? '');
    final materialNameController = TextEditingController(text: item?['material_name'] ?? '');
    final categoryController = TextEditingController(text: item?['category'] ?? '');
    final unitController = TextEditingController(text: item?['unit'] ?? 'piece');
    final currentStockController = TextEditingController(text: item?['current_stock']?.toString() ?? '0');
    final minStockController = TextEditingController(text: item?['min_stock']?.toString() ?? '0');
    final maxStockController = TextEditingController(text: item?['max_stock']?.toString() ?? '');
    final supplierController = TextEditingController(text: item?['supplier'] ?? '');
    final locationController = TextEditingController(text: item?['location'] ?? '');
    final priceController = TextEditingController(text: item?['price']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Stok Düzenle' : 'Yeni Stok Ekle'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: materialCodeController,
                  decoration: InputDecoration(
                    labelText: 'Malzeme Kodu *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Malzeme kodu gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: materialNameController,
                  decoration: InputDecoration(
                    labelText: 'Malzeme Adı *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Malzeme adı gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: 'Birim',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: currentStockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Mevcut Stok',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: minStockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Min. Stok',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: maxStockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max. Stok',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: supplierController,
                        decoration: InputDecoration(
                          labelText: 'Tedarikçi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'Konum',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Fiyat (TL)',
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
                  final inventoryData = {
                    'material_code': materialCodeController.text,
                    'material_name': materialNameController.text,
                    'category': categoryController.text,
                    'unit': unitController.text,
                    'current_stock': double.tryParse(currentStockController.text) ?? 0,
                    'min_stock': double.tryParse(minStockController.text) ?? 0,
                    'max_stock': maxStockController.text.isNotEmpty ? double.tryParse(maxStockController.text) : null,
                    'supplier': supplierController.text,
                    'location': locationController.text,
                    'price': priceController.text.isNotEmpty ? double.tryParse(priceController.text) : null,
                    'created_by': supabase.auth.currentUser!.id,
                  };

                  if (isEditing) {
                    await supabase
                        .from('inventory')
                        .update(inventoryData)
                        .eq('id', item!['id']);
                  } else {
                    await supabase
                        .from('inventory')
                        .insert(inventoryData);
                  }

                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Stok güncellendi' : 'Stok eklendi'),
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
            child: Text(isEditing ? 'Güncelle' : 'Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTransactionDialog(Map<String, dynamic> item) async {
    final formKey = GlobalKey<FormState>();
    String transactionType = 'in';
    final quantityController = TextEditingController();
    final unitPriceController = TextEditingController();
    final supplierController = TextEditingController();
    final invoiceNumberController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stok İşlemi'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${item['material_name']} (${item['material_code']})'),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: transactionType,
                decoration: InputDecoration(
                  labelText: 'İşlem Tipi *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'in', child: Text('Giriş')),
                  DropdownMenuItem(value: 'out', child: Text('Çıkış')),
                  DropdownMenuItem(value: 'adjustment', child: Text('Düzeltme')),
                ],
                onChanged: (value) => transactionType = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Miktar *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Miktar gerekli';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: unitPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Birim Fiyat (TL)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: supplierController,
                      decoration: InputDecoration(
                        labelText: 'Tedarikçi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: invoiceNumberController,
                      decoration: InputDecoration(
                        labelText: 'Fatura No',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final quantity = double.parse(quantityController.text);
                  final unitPrice = unitPriceController.text.isNotEmpty ? double.tryParse(unitPriceController.text) : null;
                  final totalPrice = unitPrice != null ? quantity * unitPrice : null;

                  // İşlem kaydı oluştur
                  await supabase.from('inventory_transactions').insert({
                    'inventory_id': item['id'],
                    'transaction_type': transactionType,
                    'quantity': quantity,
                    'unit_price': unitPrice,
                    'total_price': totalPrice,
                    'supplier': supplierController.text,
                    'invoice_number': invoiceNumberController.text,
                    'notes': notesController.text,
                    'created_by': supabase.auth.currentUser!.id,
                  });

                  // Stok miktarını güncelle
                  double newStock = item['current_stock'];
                  if (transactionType == 'in') {
                    newStock += quantity;
                  } else if (transactionType == 'out') {
                    newStock -= quantity;
                  } else if (transactionType == 'adjustment') {
                    newStock = quantity;
                  }

                  await supabase
                      .from('inventory')
                      .update({'current_stock': newStock})
                      .eq('id', item['id']);

                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İşlem kaydedildi'),
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
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteInventory(int itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stok Sil'),
        content: Text('Bu stok kalemini silmek istediğinizden emin misiniz?'),
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
            .from('inventory')
            .delete()
            .eq('id', itemId);

        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok silindi'),
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

  Color _getStockColor(double current, double min) {
    if (current <= min) {
      return Colors.red;
    } else if (current <= min * 1.5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stok Yönetimi'),
          backgroundColor: Color(0xFF186bfd),
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Stok Listesi'),
              Tab(text: 'İşlemler'),
            ],
            indicatorColor: Colors.white,
          ),
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
            ? ErrorPage(
                message: errorMessage!,
                errorType: ErrorType.data,
                onRetry: _loadData,
              )
            : TabBarView(
          children: [
            // Stok Listesi Tab
            inventory.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz stok bulunmuyor'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showInventoryDialog(),
                    child: Text('İlk Stok Ekle'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                final item = inventory[index];
                final stockColor = _getStockColor(
                  item['current_stock'] ?? 0,
                  item['min_stock'] ?? 0,
                );

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['material_name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: stockColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${item['current_stock']} ${item['unit']}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text('Kod: ${item['material_code']}'),
                        if (item['category'] != null)
                          Text('Kategori: ${item['category']}'),
                        if (item['supplier'] != null)
                          Text('Tedarikçi: ${item['supplier']}'),
                        if (item['location'] != null)
                          Text('Konum: ${item['location']}'),
                        if (item['price'] != null)
                          Text('Fiyat: ${item['price']} TL'),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Min: ${item['min_stock']}'),
                            SizedBox(width: 16),
                            if (item['max_stock'] != null)
                              Text('Max: ${item['max_stock']}'),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'transaction',
                          child: Row(
                            children: [
                              Icon(Icons.add_shopping_cart),
                              SizedBox(width: 8),
                              Text('İşlem'),
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
                        if (value == 'transaction') {
                          _showTransactionDialog(item);
                        } else if (value == 'edit') {
                          _showInventoryDialog(item);
                        } else if (value == 'delete') {
                          _deleteInventory(item['id']);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            // İşlemler Tab
            transactions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz işlem bulunmuyor'),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final isIn = transaction['transaction_type'] == 'in';

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: isIn ? Colors.green : Colors.red,
                      child: Icon(
                        isIn ? Icons.add : Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      transaction['inventory']['material_name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${transaction['quantity']} ${transaction['inventory']['unit']}'),
                        Text('Tarih: ${DateTime.parse(transaction['created_at']).toString().substring(0, 16)}'),
                        if (transaction['supplier'] != null)
                          Text('Tedarikçi: ${transaction['supplier']}'),
                        if (transaction['notes'] != null)
                          Text('Not: ${transaction['notes']}'),
                      ],
                    ),
                    trailing: transaction['total_price'] != null
                        ? Text(
                      '${transaction['total_price']} TL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showInventoryDialog(),
          backgroundColor: Color(0xFF186bfd),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}