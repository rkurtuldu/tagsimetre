import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE yolculuklar(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        tarih TEXT,
        mesafe INTEGER,
        brut INTEGER,
        yakitFiyati INTEGER,
        yakitTutari INTEGER
      )
      """);
    await database.execute("""CREATE TABLE tuketimTab(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,        
        tuketim INTEGER
      )
      """);
    await database.execute("""CREATE TABLE toplamKmTab(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        tarih TEXT,
        toplamKm INTEGER,
        gunlukYakitTutari INTEGER
      )
      """);
    await database.execute("""CREATE TABLE calismaSuresi(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        tarih TEXT,
        sure INTEGER
      )
      """);
    await database.execute("""CREATE TABLE calismaModu(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        kmMode INTEGER,
        timeMode INTEGER
      )
      """);
    await database.execute("""CREATE TABLE masraflar(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        tarih TEXT,
        masraf INTEGER,
        aciklama TEXT
      )
      """);
    await database.execute("""CREATE TABLE yakitTuru(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,        
        yakitTuru INTEGER
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'tagsidb.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createTrip(Yolculuk yolculuk) async {
    final db = await SQLHelper.db();
    final data = yolculuk.toMap();
    final id = await db.insert(
      'yolculuklar',
      data,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getTrips(String ayYil) async {
    final db = await SQLHelper.db();
    return db.query('yolculuklar',
        where: 'SUBSTR(tarih, 4, 7) = ?', whereArgs: [ayYil], orderBy: "id DESC",);
  }

  static Future<List<Map<String, dynamic>>> getDailyTrips(String bugun) async {
    final db = await SQLHelper.db();
    return db.query('yolculuklar', where: "tarih = ?", whereArgs: [bugun], orderBy: "id DESC",);
  }

  static Future<void> deleteTrip(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("yolculuklar", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Bir hata oluştu: $err");
    }
  }

  static Future<int> setConsumption(double tuketim) async {
    final db = await SQLHelper.db();
    final data = {'tuketim': tuketim};
    final id = await db.insert(
      'tuketimTab',
      data,
    );
    return id;
  }

  static Future<int> updateConsumption(double tuketim) async {
    final db = await SQLHelper.db();
    final data = {'tuketim': tuketim};
    final id = await db.update(
      'tuketimTab',
      data,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getConsumption() async {
    final db = await SQLHelper.db();
    return db.query('tuketimTab', orderBy: "id DESC", limit: 1);
  }

  static Future<int> setDailyTotal(String tarih, int toplam, double gunlukYakitTutari) async {
    final db = await SQLHelper.db();
    final data = {
      'tarih': tarih,
      'toplamKm': toplam,
      'gunlukYakitTutari' : gunlukYakitTutari,
    };
    final id = await db.insert(
      'toplamKmTab',
      data,
    );
    return id;
  }

  static Future<int> updateDailyTotal(String tarih, int toplam, double gunlukYakitTutari) async {
    final db = await SQLHelper.db();
    final data = {
      'tarih': tarih,
      'toplamKm': toplam,
      'gunlukYakitTutari' : gunlukYakitTutari,
    };
    final id = await db
        .update('toplamKmTab', data, where: "tarih = ?", whereArgs: [tarih]);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getDailyTotal(String bugun) async {
    final db = await SQLHelper.db();
    return db.query('toplamKmTab', where: "tarih = ?", whereArgs: [bugun]);
  }

  static Future<List<Map<String, dynamic>>> getMonthlyTotal(
      String ayYil) async {
    final db = await SQLHelper.db();
    return db.query('toplamKmTab',
        where: 'SUBSTR(tarih, 4, 7) = ?', whereArgs: [ayYil]);
  }

  static Future<int> setDailyTime(String tarih, int sure) async {
    final db = await SQLHelper.db();
    final data = {
      'tarih': tarih,
      'sure': sure,
    };
    final id = await db.insert(
      'calismaSuresi',
      data,
    );
    return id;
  }

  static Future<int> updateDailyTime(String tarih, int sure) async {
    final db = await SQLHelper.db();
    final data = {
      'tarih': tarih,
      'sure': sure,
    };
    final id = await db
        .update('calismaSuresi', data, where: "tarih = ?", whereArgs: [tarih]);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getDailyTime(String bugun) async {
    final db = await SQLHelper.db();
    return db.query('calismaSuresi', where: "tarih = ?", whereArgs: [bugun]);
  }

  static Future<List<Map<String, dynamic>>> getMonthlyTime(String ayYil) async {
    final db = await SQLHelper.db();
    return db.query('calismaSuresi',
        where: 'SUBSTR(tarih, 4, 7) = ?', whereArgs: [ayYil]);
  }

  static Future<int> setMode() async {
    final db = await SQLHelper.db();
    final data = {
      'kmMode': 1,
      'timeMode': 1,
    };
    final id = await db.insert(
      'calismaModu',
      data,
    );
    return id;
  }

  static Future<int> updateMode(int kmMode, int timeMode) async {
    final db = await SQLHelper.db();
    final data = {
      'kmMode': kmMode,
      'timeMode': timeMode,
    };
    final id = await db.update(
      'calismaModu',
      data,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getMode() async {
    final db = await SQLHelper.db();
    return db.query(
      'calismaModu',
    );
  }

  static Future<int> setExpense(
      String tarih, int masraf, String aciklama) async {
    final db = await SQLHelper.db();
    final data = {
      'tarih': tarih,
      'masraf': masraf,
      'aciklama': aciklama,
    };
    final id = await db.insert(
      'masraflar',
      data,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getExpense(String ayYil) async {
    final db = await SQLHelper.db();
    return db.query('masraflar',
        where: 'SUBSTR(tarih, 4, 7) = ?', whereArgs: [ayYil]);
  }

  static Future<void> deleteExpense(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("masraflar", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Bir hata oluştu: $err");
    }
  }

  static Future<int> setFuelType() async {
    final db = await SQLHelper.db();
    final data = {'YakitTuru': 2};
    final id = await db.insert(
      'yakitTuru',
      data,
    );
    return id;
  }

  static Future<int> updateFuelType(int yakitTuru) async {
    final db = await SQLHelper.db();
    final data = {
      'yakitTuru': yakitTuru,
    };
    final id = await db.update(
      'yakitTuru',
      data,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getFuelType() async {
    final db = await SQLHelper.db();
    return db.query('yakitTuru', orderBy: "id DESC", limit: 1);
  }

  static Future<List<Map<String, dynamic>>> getDailyFuel(String bugun) async {
    final db = await SQLHelper.db();
    return db.query('yolculuklar',
        where: "tarih = ?", whereArgs: [bugun], limit: 1, orderBy: "id DESC");
  }

  static Future<List<Map<String, dynamic>>> getFuelPrice() async {
    final db = await SQLHelper.db();
    return db.query('yolculuklar', orderBy: "id DESC", limit: 1);
  }

  static Future<List<String>> getMissingKmDates() async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT yolculuklar.tarih
      FROM yolculuklar
      LEFT JOIN toplamKmTab ON yolculuklar.tarih = toplamKmTab.tarih
      WHERE toplamKmTab.tarih IS NULL
    ''');
    return List<String>.from(result.map((map) => map['tarih']));
  }

  static Future<List<String>> getMissingTimeDates() async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT yolculuklar.tarih
      FROM yolculuklar
      LEFT JOIN calismaSuresi ON yolculuklar.tarih = calismaSuresi.tarih
      WHERE calismaSuresi.tarih IS NULL
    ''');
    return List<String>.from(result.map((map) => map['tarih']));
  }
}

class Yolculuk {
  String tarih;
  int mesafe;
  int brut;
  double yakitFiyati;
  double yakitTutari;

  Yolculuk(
      this.tarih, this.mesafe, this.brut, this.yakitFiyati, this.yakitTutari);

  Map<String, dynamic> toMap() {
    return {
      "tarih": tarih,
      "mesafe": mesafe,
      "brut": brut,
      "yakitFiyati": yakitFiyati,
      "yakitTutari": yakitTutari,
    };
  }
}
