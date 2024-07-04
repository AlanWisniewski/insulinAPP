import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';

class FoodModel {

  String productName;
  double energyValue;
  double weight;

  FoodModel({
    required this.productName,
    required this.energyValue,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'energyValue': energyValue,
      'weight': weight,
    };
  }

  static FoodModel fromMap(Map<String, dynamic> map) {
    return FoodModel(
      productName: map['productName'],
      energyValue: map['energyValue'],
      weight: map['weight'],
    );
  }
}

class FoodDatabase {
  static final FoodDatabase _instance = FoodDatabase._();
  static Database? _database;

  FoodDatabase._();

  factory FoodDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'food_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE food (
      productName TEXT COLLATE NOCASE,
      energyValue REAL,
      weight REAL
    )
  ''');
  }

  Future<void> insertFood(FoodModel food) async {
    final db = await database;
    await db.insert('food', food.toMap());
  }

  Future<List<FoodModel>> getFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('food');
    return List.generate(maps.length, (i) {
      return FoodModel.fromMap(maps[i]);
    });
  }
}

void importData() async {
  FoodDatabase FoodData = FoodDatabase();

  List<FoodModel> existingData = await FoodData.getFoods();
  if (existingData.isNotEmpty) {
    print('Data is already imported. Skipping import process.');
    return;
  }

  String csvString = await rootBundle.loadString('assets/food.csv');
  List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

  for (List<dynamic> row in csvTable) {
    String productName = row[0].toString();
    double energyValue = double.parse(row[1].toString());
    double weight = double.parse(row[2].toString());

    FoodModel food = FoodModel(
      productName: productName,
      energyValue: energyValue,
      weight: weight,
    );

    await FoodData.insertFood(food);
  }

  List<FoodModel> foods = await FoodData.getFoods();
  for (FoodModel food in foods) {
    print('Product Name: ${food.productName}, Energy Value: ${food.energyValue}, Weight: ${food.weight}');
  }
}