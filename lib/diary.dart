import 'package:flutter/material.dart';
import 'BottomMenu.dart';
import 'AppDatabase.dart';

class DiaryScreen extends StatefulWidget {
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<Map<String, dynamic>> _consumedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildConsumedProductList(),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    insulinAPPDatabase.clearConsumedProducts().then((_) {
                      setState(() {
                        _consumedProducts = [];
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Clear'),
                ),
                  ElevatedButton(
                    onPressed: () {
                      _calculate();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Calculate'),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (int index) {
          handleBottomNavigationTap(context, index);
        },
      ),
    );
  }

  Widget _buildConsumedProductList() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: insulinAPPDatabase.getConsumedProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _consumedProducts = snapshot.data ?? [];

            if (_consumedProducts.isEmpty) {
              return Center(
                child: Text('Diary is empty. Add products to the diary.'),
              );
            }

            return Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _buildConsumedProductListView(_consumedProducts),
            );
          }
        },
      ),
    );
  }

  Widget _buildConsumedProductListView(List<Map<String, dynamic>> consumedProducts) {
    return ListView.builder(
      itemCount: consumedProducts.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> product = consumedProducts[index];
        return ListTile(
          title: Text(product['productName']),
          subtitle: Text('Portion: ${product['portion']} g, Carbohydrates: ${product['consumedEnergy']} g'),
        );
      },
    );
  }

  void _calculate() async {
    if (_consumedProducts.isEmpty) {
      // Display a message that the diary is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Diary is Empty'),
          content: Text('You need to add products to the diary before calculating.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    String? userName = await insulinAPPDatabase.getUserName();
    double carbohydrateExchange = await insulinAPPDatabase.getCarbohydrateExchange();

    double totalEnergy = _calculateTotalEnergy(_consumedProducts);
    double calculatedResult = totalEnergy / carbohydrateExchange;

    int roundedResult = calculatedResult.round();

    await insulinAPPDatabase.insertBolus(roundedResult);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Calculation Result'),
        content: Text('Hello $userName!\nTotal Carbohydrates: $totalEnergy g\nSuggested bolus: $roundedResult units'),
        actions: [
          TextButton(
            onPressed: () {
              insulinAPPDatabase.clearConsumedProducts().then((_) {
                setState(() {
                  _consumedProducts = [];
                });
              });
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  double _calculateTotalEnergy(List<Map<String, dynamic>> consumedProducts) {
    double totalEnergy = 0.0;
    for (var product in consumedProducts) {
      totalEnergy += product['consumedEnergy'];
    }
    return totalEnergy;
  }
}

void handleBottomNavigationTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pushReplacementNamed(context, '/');
      break;
    case 1:
      Navigator.pushReplacementNamed(context, '/search');
      break;
    case 2:
      break;
    case 3:
      Navigator.pushReplacementNamed(context, '/settings');
      break;
  }
}
