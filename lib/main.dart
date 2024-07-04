import 'package:flutter/material.dart';
import 'search.dart';
import 'Settings.dart';
import 'BottomMenu.dart';
import 'diary.dart';
import 'BMI.dart';
import 'BasalInsulinEval.dart';
import 'AppDatabase.dart';
import 'FoodProducts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await insulinAPPDatabase.initializeDatabase();
  importData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: insulinAPPDatabase.getCarbohydrateExchange(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {

          return MaterialApp(
            theme: ThemeData(
              primaryColor: Colors.blue,
              fontFamily: 'Roboto',
            ),
            home: HomeScreen(),
            routes: {
              '/search': (context) => SearchScreen(),
              '/settings': (context) => SettingsScreen(),
              '/diary': (context) => DiaryScreen(),
              '/BMI': (context) => BMIEvaluationScreen(),
              '/basal_insulin_evaluation': (context) => BasalInsulinEvaluationScreen(),
            },
          );
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'InsulinAPP',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<String?>(
                  future: insulinAPPDatabase.getUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      );
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Text(
                          'Hello!',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          Center(
                            child: Text(
                              'Hello ${snapshot.data}!',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          FutureBuilder<int?>(
                            future: getLastBolus(),
                            builder: (context, lastBolusSnapshot) {
                              return Text(
                                'Your last insulin dose: ${lastBolusSnapshot.data ?? '0.00'}',
                                style: TextStyle(fontSize: 16.0),
                              );
                            },
                          ),
                          SizedBox(height: 8.0),
                          FutureBuilder<double>(
                            future: getAverageBolus(),
                            builder: (context, averageBolusSnapshot) {
                              return Column(
                                children: [
                                  Text(
                                    'Average of your last 7 doses: ${averageBolusSnapshot.data?.toStringAsFixed(2) ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  SizedBox(height: 8.0),
                                  FutureBuilder<double>(
                                    future: getPrognosis(),
                                    builder: (context, prognosisSnapshot) {
                                      return Text(
                                        'Prognosis of next insulin dose: ${prognosisSnapshot.data?.toStringAsFixed(0) ?? '0.00'}',
                                        style: TextStyle(fontSize: 16.0),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/BMI');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text('Evaluate BMI'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context,
                                              '/basal_insulin_evaluation');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text('Evaluate Basal insulin'),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (int index) {
          handleBottomNavigationTap(context, index);
        },
      ),
    );
  }

  Future<int?> getLastBolus() async {
    int? lastBolus = await insulinAPPDatabase.getLastBolus();
    return lastBolus;
  }

  Future<double> getPrognosis() async {

    List<int> last7Bolus = await insulinAPPDatabase.getLast7Bolus();

    double averageBolus = last7Bolus.reduce((a, b) => a + b) / last7Bolus.length;
    double prognosis = averageBolus * 1.1;

    return prognosis;
  }

  Future<double> getAverageBolus() async {
    List<int> last7Bolus = await insulinAPPDatabase.getLast7Bolus();
    double averageBolus = last7Bolus.isNotEmpty
        ? last7Bolus.reduce((a, b) => a + b) / last7Bolus.length
        : 0.0;
    return averageBolus;
  }

  void handleBottomNavigationTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
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
