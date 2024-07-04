import 'package:flutter/material.dart';
import 'AppDatabase.dart';

class BMIEvaluationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Evaluation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<double>(
                future: calculateBMI(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    double bmi = snapshot.data ?? 0.0;

                    if (bmi == -1.0) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Insufficient information, please complete user parameters in the settings.',
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ],
                      );
                    }

                    String formattedBMI = bmi.toStringAsFixed(2);
                    String bmiMessage = getBMIMessage(bmi);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Your BMI is: $formattedBMI'),
                        SizedBox(height: 16.0),
                        Text('$bmiMessage'),
                        SizedBox(height: 16.0),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 32.0),
              FutureBuilder<double>(
                future: calculateIdealBodyWeight(),
                builder: (context, idealWeightSnapshot) {
                  if (idealWeightSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (idealWeightSnapshot.hasError) {
                    return Text('Error: ${idealWeightSnapshot.error}');
                  } else {
                    double idealWeight = idealWeightSnapshot.data ?? -1.0;
                    String formattedIdealWeight = idealWeight.toStringAsFixed(1);

                    if (idealWeight == -1.0) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ' ',
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ],
                      );
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Your Ideal Body Weight is: $formattedIdealWeight kg'),
                            SizedBox(width: 8.0),
                            _buildBMIRow(context),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMIRow(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ideal body weight formula'),
              content: Text('Many specialists recommend using the gender-specific Acute Respiratory Distress Syndrome Network (ARDSnet) formulas to calculate ideal body weight. Ideal body weight is computed in men as 50 + (0.91 × [height in centimeters − 152.4]) and in women as 45.5 + (0.91 × [height in centimeters − 152.4]).'),
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

  Future<double> calculateBMI() async {
    double weight = await insulinAPPDatabase.getWeight();
    double height = await insulinAPPDatabase.getHeight();

    if (weight == 0.0 || height == 0.0) {
      return -1.0;
    }

    double height1 = height / 100;
    double height2 = height1 * height1;
    double bmi = weight / height2;

    return bmi;
  }

  Future<double> calculateIdealBodyWeight() async {
    double height = await insulinAPPDatabase.getHeight();

    if (height == 0.0) {
      return -1.0;
    }

    double heightInCentimeters = height;
    double idealBodyWeight;

    if (await insulinAPPDatabase.getSex() == "Female") {
      idealBodyWeight = 45.5 + (0.91 * (heightInCentimeters - 152.4));
    } else {
      idealBodyWeight = 50 + (0.91 * (heightInCentimeters - 152.4));
    }

    return idealBodyWeight;
  }

  String getBMIMessage(double bmi) {
    if (bmi < 18.5) {
      return 'Your BMI is too low. Consider gaining weight to avoid health complications.';
    }
    else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Your BMI is normal. Congratulations!';
    } else if (bmi >= 25 && bmi < 29.9) {
      return "Your BMI is too high, indicating overweight. Overweight can impact your body's insulin resistance. For the sake of your health, consider losing weight.";
    } else {
      return 'Your BMI is significantly high, indicating obesity. Consider seeking specialized help to develop a weight loss plan, as your current weight may drastically affect insulin resistance!';
    }
  }
}