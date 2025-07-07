import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> inventory = [];
  bool loading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final result = await supabase
          .from('inventory')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        inventory = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Stok verileri yüklenirken hata oluştu:\n${e.toString()}';
        loading = false;
      });
    }
  }

  Future<void> addInventoryItem() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => InventoryItemDialog(
        onSave: (itemData) async {
          try {
            await supabase.from('inventory').insert({
              'material_code': itemData['material_code'],
              'material_name': itemData['material_name'],
              'category': itemData['category'],
              'unit': itemData['unit'],
              'current_stock': double.parse(itemData['current_stock']),
              'min_stock': double.parse(itemData['min_stock']),
              'max_stock': itemData['max_stock'].isNotEmpty ? double.parse(itemData['max_stock']) : null,
              'supplier': itemData['supplier'],
              'location': itemData['location'],
            });
            Navigator.pop(context);
            await fetchInventory();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Stok kalemi eklendi')),
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

  Future<void> updateStock(int itemId, double newStock) async {
    try {
      await supabase
          .from('inventory')
          .update({'current_stock': newStock})
          .eq('id', itemId);
      await fetchInventory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok güncellendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredInventory {
    if (searchQuery.isEmpty) return inventory;
    return inventory.where((item) {
      final name = item['material_name']?.toString().toLowerCase() ?? '';
      final code = item['material_code']?.toString().toLowerCase() ?? '';
      final category = item['category']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query) || category.contains(query);
    }).toList();
  }

  Color _getStockStatusColor(double current, double min) {
    if (current <= min * 0.5) return Colors.red;
    if (current <= min) return Colors.orange;
    return Colors.green;
  }

  String _getStockStatusText(double current, double min) {
    if (current <= min * 0.5) return 'Kritik';
    if (current <= min) return 'Düşük';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 16);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double labelFont = ResponsiveHelper.getResponsiveFontSize(context, 16);
    double cardRadius = ResponsiveHelper.getResponsiveWidth(context, 12);

    return Scaffold(
      appBar: AppBar(
        title: Text("Stok Takibi", style: TextStyle(fontSize: titleFont)),
        backgroundColor: Color(0xFF186bfd),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: addInventoryItem,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchInventory,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: labelFont)))
            : Column(
          children: [
            // Arama Çubuğu
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Malzeme ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

            // Stok Özeti
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF186bfd).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory, color: Color(0xFF186bfd)),
                  SizedBox(width: 8),
                  Text(
                    '${filteredInventory.length} malzeme bulundu',
                    style: TextStyle(
                      fontSize: labelFont,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF186bfd),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

            // Stok Listesi
            Expanded(
              child: filteredInventory.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      searchQuery.isEmpty
                          ? 'Henüz stok kalemi bulunmuyor'
                          : 'Arama sonucu bulunamadı',
                      style: TextStyle(fontSize: labelFont, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredInventory.length,
                itemBuilder: (context, index) {
                  final item = filteredInventory[index];
                  final currentStock = (item['current_stock'] ?? 0).toDouble();
                  final minStock = (item['min_stock'] ?? 0).toDouble();
                  final stockStatusColor = _getStockStatusColor(currentStock, minStock);

                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: stockStatusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory,
                          color: stockStatusColor,
                        ),
                      ),
                      title: Text(
                        item['material_name'] ?? 'Malzeme',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kod: ${item['material_code'] ?? 'N/A'}"),
                          Text("Kategori: ${item['category'] ?? 'N/A'}"),
                          Text("Konum: ${item['location'] ?? 'N/A'}"),
                          Row(
                            children: [
                              Text("Stok: ${currentStock} ${item['unit'] ?? 'adet'}"),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stockStatusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStockStatusText(currentStock, minStock),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: stockStatusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'update') {
                            _showUpdateStockDialog(item);
                          } else if (value == 'details') {
                            _showItemDetails(item);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'update',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Stok Güncelle'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.info, size: 16),
                                SizedBox(width: 8),
                                Text('Detaylar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(Map<String, dynamic> item) {
    final TextEditingController stockController = TextEditingController(
      text: item['current_stock'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stok Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${item['material_name']}'),
            SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Yeni Stok Miktarı',
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
            onPressed: () {
              final newStock = double.tryParse(stockController.text);
              if (newStock != null) {
                updateStock(item['id'], newStock);
                Navigator.pop(context);
              }
            },
            child: Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Malzeme Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kod: ${item['material_code']}'),
            Text('Ad: ${item['material_name']}'),
            Text('Kategori: ${item['category'] ?? 'N/A'}'),
            Text('Birim: ${item['unit'] ?? 'adet'}'),
            Text('Mevcut Stok: ${item['current_stock']}'),
            Text('Minimum Stok: ${item['min_stock']}'),
            if (item['max_stock'] != null) Text('Maksimum Stok: ${item['max_stock']}'),
            Text('Tedarikçi: ${item['supplier'] ?? 'N/A'}'),
            Text('Konum: ${item['location'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }
}

class InventoryItemDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  InventoryItemDialog({required this.onSave});

  @override
  _InventoryItemDialogState createState() => _InventoryItemDialogState();
}

class _InventoryItemDialogState extends State<InventoryItemDialog> {
  final TextEditingController materialCodeController = TextEditingController();
  final TextEditingController materialNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController currentStockController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final TextEditingController maxStockController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String selectedUnit = 'piece';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Yeni Stok Kalemi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: materialCodeController,
              decoration: InputDecoration(
                labelText: 'Malzeme Kodu *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: materialNameController,
              decoration: InputDecoration(
                labelText: 'Malzeme Adı *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedUnit,
              decoration: InputDecoration(
                labelText: 'Birim',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'piece', child: Text('Adet')),
                DropdownMenuItem(value: 'kg', child: Text('Kilogram')),
                DropdownMenuItem(value: 'm', child: Text('Metre')),
                DropdownMenuItem(value: 'liter', child: Text('Litre')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedUnit = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: currentStockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Mevcut Stok *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: minStockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Minimum Stok *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: maxStockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Maksimum Stok',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: supplierController,
              decoration: InputDecoration(
                labelText: 'Tedarikçi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Konum',
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
            if (materialCodeController.text.isNotEmpty &&
                materialNameController.text.isNotEmpty &&
                currentStockController.text.isNotEmpty &&
                minStockController.text.isNotEmpty) {
              widget.onSave({
                'material_code': materialCodeController.text,
                'material_name': materialNameController.text,
                'category': categoryController.text,
                'unit': selectedUnit,
                'current_stock': currentStockController.text,
                'min_stock': minStockController.text,
                'max_stock': maxStockController.text,
                'supplier': supplierController.text,
                'location': locationController.text,
              });
            }
          },
          child: Text('Kaydet'),
        ),
      ],
    );
  }
}