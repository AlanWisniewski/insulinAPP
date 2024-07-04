import 'package:flutter/material.dart';
import 'FoodProducts.dart';
import 'AddConsumedFood.dart';
import 'BottomMenu.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<FoodModel> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter product name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    _loadDataFromDatabase();
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (int index) {
          handleBottomNavigationTap(context, index);
        },
      ),
    );
  }

  void _showAddProductDialog() {
    String productName = '';
    double energyValue = 0.0;
    double weight = 0.0;

    final productNameController = TextEditingController();
    final energyValueController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  onSubmitted: (value) {
                    productName = value;
                  },
                ),
                TextField(
                  controller: energyValueController,
                  decoration: InputDecoration(labelText: 'Carbohydrates'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(labelText: 'Weight'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () {
                    productName = productNameController.text;
                    energyValue = double.tryParse(energyValueController.text) ?? 0.0;
                    weight = double.tryParse(weightController.text) ?? 0.0;

                    _addProductToDatabase(productName, energyValue, weight);
                    Navigator.pop(context);
                  },
                  child: Text('Add Product'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addProductToDatabase(String productName, double energyValue, double weight) async {
    try {
      if (productName.isEmpty || energyValue <= 0.0 || weight <= 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all the fields.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      FoodDatabase FoodData = FoodDatabase();
      FoodModel food = FoodModel(
        productName: productName,
        energyValue: energyValue,
        weight: weight,
      );
      await FoodData.insertFood(food);

      List<FoodModel> foods = await FoodData.getFoods();
      for (FoodModel food in foods) {
        print('Product Name: ${food.productName}, Energy Value: ${food.energyValue}, Weight: ${food.weight}');
      }
    } catch (e) {
      print('Error adding product to database: $e');
    }
  }

  void _loadDataFromDatabase() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the name of a product.'),
        ),
      );
      return;
    }

    print('Searching for: ${_searchController.text}');

    FoodDatabase FoodData = FoodDatabase();
    List<FoodModel> results = await FoodData.getFoods();

    String query = _searchController.text.toLowerCase();
    results = results.where((result) {
      var productName = result.productName;

        String productNameString = productName.replaceAll('"', '').toLowerCase();
        return productNameString.contains(query);

    }).toList();

    setState(() {
      searchResults = results;
    });
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return Center(
        child: Text('No results found.'),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        String productName = searchResults[index].productName;
        double energyValue = searchResults[index].energyValue;
        double weight = searchResults[index].weight;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddConsumedScreen(
                  productName: productName,
                  energyValue: energyValue,
                  weight: weight,
                ),
              ),
            );
          },
          child: ListTile(
            title: Text('$productName'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carbohydrates: ${energyValue.toStringAsFixed(2)} per $weight grams'),
              ],
            ),
          ),
        );
      },
    );
  }

  void handleBottomNavigationTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/diary');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }
}