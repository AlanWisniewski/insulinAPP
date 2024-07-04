import 'package:flutter/material.dart';
import 'AppDatabase.dart';

class BasalInsulinEvaluationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basal Insulin Evaluation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FutureBuilder<double>(
            future: calculateBasalInsulin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                double basalInsulin = snapshot.data ?? 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text:
                          'According to a mathematical formula created by specialists at the University of California, your Basal Insulin dose is: ',
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: (basalInsulin == 0.0)
                                  ? 'Insufficient information, please complete user parameters in the settings.'
                                  : '$basalInsulin units',
                              style: TextStyle(
                                fontWeight: (basalInsulin == 0.0)
                                    ? FontWeight.bold
                                    : FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: (basalInsulin == 0.0)
                                  ? ''
                                  : '. It also depends on other factors such as insulin resistance or other chronic diseases. Always remember to consult your results with an endocrinologist.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<double> calculateBasalInsulin() async {
    double weight = await insulinAPPDatabase.getWeight();

    if (weight == 0.0) {
      return 0.0;
    }

    double converter = weight * 2.20462;
    double basalInsulin = converter / 4;
    double result = basalInsulin / 2;

    basalInsulin = double.parse(result.toStringAsFixed(0));

    return basalInsulin;
  }
}