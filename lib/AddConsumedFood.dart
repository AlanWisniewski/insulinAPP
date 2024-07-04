import 'package:flutter/material.dart';
import 'AppDatabase.dart';

class AddConsumedScreen extends StatefulWidget {
  final String productName;
  final double energyValue;
  final double weight;

  AddConsumedScreen({
    required this.productName,
    required this.energyValue,
    required this.weight,
  });

  @override
  _AddConsumedScreenState createState() => _AddConsumedScreenState();
}

class _AddConsumedScreenState extends State<AddConsumedScreen> {
  TextEditingController _portionsController = TextEditingController();
  double consumedPortions = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Consumed Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${widget.productName}'),
            SizedBox(height: 16.0),
            Text('Carbohydrates: ${widget.energyValue} per ${widget.weight} grams'),
            SizedBox(height: 16.0),
            TextField(
              controller: _portionsController,
              decoration: InputDecoration(labelText: 'Enter portions consumed'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _addConsumedProduct();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Add to Diary'),
            ),
          ],
        ),
      ),
    );
  }

  void _addConsumedProduct() {
    setState(() {
      consumedPortions = double.tryParse(_portionsController.text) ?? 1.0;
      double consumedEnergy = (widget.energyValue * consumedPortions);
      double portion =  (widget.weight * consumedPortions);

      insulinAPPDatabase.insertConsumedProduct(
        productName: widget.productName,
        consumedPortions: consumedPortions,
        consumedEnergy: consumedEnergy,
        portion: portion,
      );

      print('Product: ${widget.productName}');
      print('Consumed Portions: $portion grams');
      print('Consumed Carbohydrates: $consumedEnergy');
    });
    Navigator.pop(context);
  }
}