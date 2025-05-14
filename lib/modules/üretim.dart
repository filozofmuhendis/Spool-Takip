import 'package:flutter/material.dart';

class WorkshopProductionPage extends StatefulWidget {
  @override
  _WorkshopProductionPageState createState() => _WorkshopProductionPageState();
}

class _WorkshopProductionPageState extends State<WorkshopProductionPage> {
  // Ürün listesi
  final List<Map<String, dynamic>> productionData = [
    {
      'productId': 'PRD-1001',
      'model': 'Model No: 51091',
      'notes': 'Dikiş makinesi sorunu nedeniyle gecikti.',
      'stages': {
        'Dikim': false,
        'Kontrol': false,
        'Ütü': false,
        'Paket': false,
      },
    },
    {
      'productId': 'PRD-1002',
      'model': 'Model No: 6735',
      'notes': 'Aksesuar eksikliği giderildi.',
      'stages': {
        'Dikim': true,
        'Kontrol': true,
        'Ütü': false,
        'Paket': false,
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Üretim Takip',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
            height: 1,
          ),
          itemCount: productionData.length,
          itemBuilder: (context, index) {
            final product = productionData[index];

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün ID ve Model
                    Text(
                      'Ürün ID: ${product['productId']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product['model'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Aşama Checkbox'ları
                    Text(
                      'Aşamalar:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: product['stages'].keys.map<Widget>((stage) {
                        return CheckboxListTile(
                          title: Text(stage),
                          value: product['stages'][stage],
                          onChanged: (value) {
                            setState(() {
                              product['stages'][stage] = value;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    // Notlar Bölümü
                    SizedBox(height: 16),
                    Text(
                      'Notlar:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(
                        text: product['notes'],
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Not ekleyin...',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          product['notes'] = value;
                        });
                      },
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
