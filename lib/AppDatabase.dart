import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class insulinAPPDatabase {

  static Database? _database;
  static const String bolusTable = 'bolus_data';
  static const String settingsTable = 'settings_data';
  static const String consumedTable = 'consumed_data';

  static Future<void> initializeDatabase() async {
    if (_database == null) {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'insulinapp_database.db'),
        onCreate: (db, version) {
          _createBolusTable(db);
          _createSettingsTable(db);
          _createConsumedTable(db);
        },
        version: 1,
      );
    }
  }

  static void _createBolusTable(Database db) {
    db.execute(
      'CREATE TABLE $bolusTable(doses INTEGER)',
    );
  }

  static void _createSettingsTable(Database db) {
    db.execute(
      'CREATE TABLE $settingsTable(name TEXT, carbohydrateExchange REAL, weight REAL, height REAL, sex TEXT)',
    );
  }

  static void _createConsumedTable(Database db) {
    db.execute(
      '''
      CREATE TABLE $consumedTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT,
        consumedPortions REAL,
        consumedEnergy REAL,
        portion REAL
      )
      ''',
    );
  }

  static Future<void> insertBolus(int doses) async {
    await initializeDatabase();
    await _database!.insert(
      bolusTable,
      {'doses': doses},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int?> getLastBolus() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> result = await _database!.query(
      bolusTable,
      orderBy: 'ROWID DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['doses'] as int;
    }
    return null;
  }

  static Future<List<int>> getLast7Bolus() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> result = await _database!.query(
      bolusTable,
      orderBy: 'ROWID DESC',
      limit: 7,
    );
    return result.map((row) => row['doses'] as int).toList();
  }

  static Future<void> saveSettings(String? name, double carbohydrateExchange, double weight, double height, String sex) async {
    await initializeDatabase();
    final Database db = await _database!;
    final List<Map<String, dynamic>> existingData = await db.query(settingsTable, columns: ['name']);

    if ((name != null && name.isNotEmpty) || existingData.isNotEmpty) {
      if (existingData.isNotEmpty) {
        await db.update(
          settingsTable,
          {
            'name': name,
            'carbohydrateExchange': carbohydrateExchange,
            'weight': weight,
            'height': height,
            'sex': sex,
          },
        );
      } else {
        await db.insert(
          settingsTable,
          {
            'name': name,
            'carbohydrateExchange': carbohydrateExchange,
            'weight': weight,
            'height': height,
            'sex': sex,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

  static Future<String?> getUserName() async {
    final Database db = await _database!;
    final List<Map<String, dynamic>> maps = await db.query(settingsTable, columns: ['name']);

    final List<String?> nonEmptyNames = maps.map((entry) => entry['name'] as String?).where((name) => name != null && name.isNotEmpty).toList();

    if (nonEmptyNames.isNotEmpty) {
      return nonEmptyNames.first;
    } else {
      return "Guest";
    }
  }

  static Future<double> getCarbohydrateExchange() async {
    final Database db = await _database!;
    final List<Map<String, dynamic>> maps = await db.query(settingsTable, columns: ['carbohydrateExchange']);

    if (maps.isNotEmpty) {
      return maps.first['carbohydrateExchange'] as double;
    } else {
      return 10.0;
    }
  }

  static Future<double> getWeight() async {
    final Database db = await _database!;
    final List<Map<String, dynamic>> maps = await db.query(settingsTable, columns: ['weight']);

    if (maps.isNotEmpty) {
      return maps.first['weight'] as double;
    } else {
      return 0.0;
    }
  }

  static Future<double> getHeight() async {
    final Database db = await _database!;
    final List<Map<String, dynamic>> maps = await db.query(settingsTable, columns: ['height']);

    if (maps.isNotEmpty) {
      return maps.first['height'] as double;
    } else {
      return 0.0;
    }
  }

  static Future<String> getSex() async {
    final Database db = await _database!;
    final List<Map<String, dynamic>> maps = await db.query(settingsTable, columns: ['sex']);

    if (maps.isNotEmpty) {
      return maps.first['sex'] as String;
    } else {
      return "male";
    }
  }

  static Future<void> insertConsumedProduct({
    required String productName,
    required double consumedPortions,
    required double consumedEnergy,
    required double portion,
  }) async {
    await initializeDatabase();
    if (_database == null) {
      throw Exception("Database not initialized");
    }

    await _database!.insert(
      consumedTable,
      {
        'productName': productName,
        'consumedPortions': consumedPortions,
        'consumedEnergy': consumedEnergy,
        'portion': portion,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getConsumedProducts() async {
    await initializeDatabase();
    if (_database == null) {
      throw Exception("Database not initialized");
    }

    return await _database!.query(consumedTable);
  }

  static Future<void> clearConsumedProducts() async {
    await initializeDatabase();
    if (_database == null) {
      throw Exception("Database not initialized");
    }

    await _database!.delete(consumedTable);
  }
}