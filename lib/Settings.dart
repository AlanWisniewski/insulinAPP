import 'package:flutter/material.dart';
import 'BottomMenu.dart';
import 'AppDatabase.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _name = '';
  double _carbohydrateExchange = 10.0;
  double _weight = 0.0;
  double _height = 0.0;
  String _sex = 'Male';

  final List<String> _sexOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    String? name = await insulinAPPDatabase.getUserName();
    double carbohydrateExchange = await insulinAPPDatabase.getCarbohydrateExchange();
    double weight = await insulinAPPDatabase.getWeight();
    double height = await insulinAPPDatabase.getHeight();
    String sex = await insulinAPPDatabase.getSex();

    setState(() {
      _name = name ?? '';
      _carbohydrateExchange = carbohydrateExchange > 0.0 ? carbohydrateExchange : 10.0;
      _weight = weight > 0.0 ? weight : 0.0;
      _height = height > 0.0 ? height : 0.0;
      _sex = _sexOptions.contains(sex) ? sex : _sexOptions.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name:'),
                SizedBox(height: 8.0),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Enter your name',
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Text('Carbohydrate Exchange:'),
                    SizedBox(width: 8.0),
                    _buildCarbExchangeRow(),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    SizedBox(
                      width: 40.0,
                      child: TextField(
                        onChanged: (value) {
                          double parsedValue = double.tryParse(value) ?? 10.0;
                          setState(() {
                            _carbohydrateExchange = parsedValue > 0.0 ? parsedValue : 10.0;
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          errorText: _carbohydrateExchange <= 0.0 ? 'Enter a number greater than 0' : null,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text('g'),
                  ],
                ),
                SizedBox(height: 16.0),
                // Input field for Weight
                Text('Weight (kg):'),
                SizedBox(height: 8.0),
                TextField(
                  onChanged: (value) {
                    double parsedValue = double.tryParse(value) ?? 0.0;
                    setState(() {
                      _weight = parsedValue > 0.0 ? parsedValue : 0.0;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    errorText: _weight <= 0.0 ? 'Enter a number greater than 0' : null,
                  ),
                ),
                SizedBox(height: 16.0),
                // Input field for Height
                Text('Height (cm):'),
                SizedBox(height: 8.0),
                TextField(
                  onChanged: (value) {
                    double parsedValue = double.tryParse(value) ?? 0.0;
                    setState(() {
                      _height = parsedValue > 0.0 ? parsedValue : 0.0;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    errorText: _height <= 0.0 ? 'Enter a number greater than 0' : null,
                  ),
                ),
                SizedBox(height: 16.0),
                // Dropdown for Sex
                Text('Sex:'),
                SizedBox(height: 8.0),
                DropdownButton<String>(
                  value: _sex,
                  onChanged: (String? newValue) {
                    setState(() {
                      _sex = newValue!;
                    });
                  },
                  items: _sexOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    await insulinAPPDatabase.saveSettings(_name, _carbohydrateExchange, _weight, _height, _sex);

                    _loadSettings();

                    print('Name: $_name');
                    print('Carbohydrate Exchange: $_carbohydrateExchange g');
                    print('Weight: $_weight kg');
                    print('Height: $_height cm');
                    print('Sex: $_sex');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save Settings'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          currentIndex: 3,
          onTap: (int index) {
            handleBottomNavigationTap(context, index);
          },
        ),
      ),
    );
  }
  Widget _buildCarbExchangeRow() {
    return GestureDetector(
      onTap: () {
        // Show explanation upon clicking
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Carbohydrate Exchange'),
              content: Text('The carbohydrate exchange represents the amount of carbohydrates in grams covered by 1 unit of insulin. This value should be determined with an endocrinologist.\n\nExample: A standard carbohydrate exchange is 10g per 1 unit of insulin. In this case, for a meal consisting of 80 grams of carbohydrates, 8 units of insulin are needed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue, // Change the color as needed
        ),
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
        Navigator.pushReplacementNamed(context, '/diary');
        break;
      case 3:
        break;
    }
  }
}

