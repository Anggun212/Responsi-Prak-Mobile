export 'app_bloc_observer.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'kasir.db');

    return openDatabase(path, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT, totalPrice REAL)',
      );
    }, version: 1);
  }

  static Future<void> insertTransaction(double totalPrice) async {
    final db = await initializeDatabase();
    await db.insert(
      'transactions',
      {'totalPrice': totalPrice},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await initializeDatabase();
    return await db.query('transactions');
  }
}
