import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants.dart';

/// Singleton helper for the local SQLite database.
///
/// Tables: users, cars, trips, advances, bills, payments, leaves, bata_config.
class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'travel_fleet.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Users ───────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // ── Cars ────────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE cars (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleNumber TEXT NOT NULL UNIQUE,
        vehicleType TEXT NOT NULL,
        currentKm REAL NOT NULL DEFAULT 0,
        nextServiceKm REAL NOT NULL DEFAULT 0,
        fcExpiryDate TEXT NOT NULL,
        insuranceExpiryDate TEXT NOT NULL,
        pucExpiryDate TEXT NOT NULL
      )
    ''');

    // ── Trips ───────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pickupDate TEXT NOT NULL,
        pickupTime TEXT NOT NULL,
        pickupLocation TEXT NOT NULL,
        numberOfDays INTEGER NOT NULL,
        placesToVisit TEXT NOT NULL,
        carId INTEGER,
        driverId INTEGER,
        status TEXT NOT NULL DEFAULT 'created',
        startTime TEXT,
        endTime TEXT,
        startingKm REAL,
        endingKm REAL,
        toll REAL DEFAULT 0,
        permit REAL DEFAULT 0,
        parking REAL DEFAULT 0,
        otherCharges REAL DEFAULT 0,
        FOREIGN KEY (carId) REFERENCES cars(id),
        FOREIGN KEY (driverId) REFERENCES users(id)
      )
    ''');

    // ── Advances ────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE advances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        amount REAL NOT NULL,
        advanceType TEXT NOT NULL,
        enteredBy TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (tripId) REFERENCES trips(id)
      )
    ''');

    // ── Bills ───────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        billDate TEXT NOT NULL,
        tripDate TEXT NOT NULL,
        vehicleNumber TEXT NOT NULL,
        placesToVisit TEXT NOT NULL,
        startDateTime TEXT NOT NULL,
        endDateTime TEXT NOT NULL,
        startingKm REAL NOT NULL,
        endingKm REAL NOT NULL,
        totalKm REAL NOT NULL,
        rentType TEXT NOT NULL,
        rentUnits INTEGER NOT NULL,
        ratePerUnit REAL NOT NULL,
        ratePerKm REAL NOT NULL,
        kmAmount REAL NOT NULL,
        driverBata REAL NOT NULL,
        toll REAL DEFAULT 0,
        permit REAL DEFAULT 0,
        parking REAL DEFAULT 0,
        otherCharges REAL DEFAULT 0,
        totalAmount REAL NOT NULL,
        advanceAmount REAL NOT NULL,
        payableAmount REAL NOT NULL,
        FOREIGN KEY (tripId) REFERENCES trips(id)
      )
    ''');

    // ── Payments ────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billId INTEGER NOT NULL,
        amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        date TEXT NOT NULL,
        remarks TEXT,
        FOREIGN KEY (billId) REFERENCES bills(id)
      )
    ''');

    // ── Leaves ──────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE leaves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        driverId INTEGER NOT NULL,
        date TEXT NOT NULL,
        leaveType TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        reason TEXT,
        FOREIGN KEY (driverId) REFERENCES users(id)
      )
    ''');

    // ── Bata Config (per vehicle type) ──────────────────────────────────────
    await db.execute('''
      CREATE TABLE bata_config (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleType TEXT NOT NULL UNIQUE,
        bataPerDay REAL NOT NULL
      )
    ''');

    // Seed default bata configuration
    await _seedBataConfig(db);

    // Seed default owner account
    await _seedDefaultOwner(db);
  }

  /// Seeds initial bata rates per vehicle type.
  Future<void> _seedBataConfig(Database db) async {
    final defaults = {
      'Sedan': 350.0,
      'MPV': 500.0,
      'SUV': 600.0,
      'Tempo Traveller': 800.0,
      'Bus': 1200.0,
    };
    for (final entry in defaults.entries) {
      await db.insert('bata_config', {
        'vehicleType': entry.key,
        'bataPerDay': entry.value,
      });
    }
  }

  /// Seeds a default owner account so the app is usable on first launch.
  Future<void> _seedDefaultOwner(Database db) async {
    await db.insert('users', {
      'name': 'Admin Owner',
      'phone': '0000000000',
      'role': AppConstants.roleOwner,
      'username': 'owner',
      'password': 'owner123',
    });
  }

  // ── Generic CRUD helpers ──────────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }
}
