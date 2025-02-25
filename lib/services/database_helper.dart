import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';
import '../models/encomenda.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('encomendas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // versão atualizada
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Novo método para tratar upgrades de versão do banco
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      if (!await _columnExists(db, 'encomendas', 'syncStatus')) {
        await db.execute(
            'ALTER TABLE encomendas ADD COLUMN syncStatus INTEGER DEFAULT 0');
      }
      if (!await _columnExists(db, 'encomendas', 'remoteId')) {
        await db.execute('ALTER TABLE encomendas ADD COLUMN remoteId INTEGER');
      }
    }
  }

  Future<bool> _columnExists(Database db, String table, String column) async {
    final result = await db.rawQuery("PRAGMA table_info($table)");
    return result.any((row) => row['name'] == column);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE encomendas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        codigoRastreio TEXT NOT NULL,
        transportadora TEXT NOT NULL,
        status TEXT NOT NULL,
        dataCriacao TEXT NOT NULL,
        syncStatus INTEGER DEFAULT 0,   -- 0 = não sincronizado, 1 = sincronizado
        remoteId INTEGER               -- ID da encomenda no servidor (opcional)
    )
    ''');
  }

  Future<int> inserirEncomenda(Encomenda encomenda) async {
    final db = await instance.database;
    //await Future.delayed(Duration(seconds: 80));
    // Certifique-se de que o objeto Encomenda inclua o campo syncStatus = 0
    Map<String, dynamic> json = encomenda.toJson();
    json['syncStatus'] = 0;
    return await db.insert(
      'encomendas',
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Encomenda>> listarEncomendas() async {
    final db = await instance.database;
    final result = await db.query('encomendas');
    return result.map((json) => Encomenda.fromJson(json)).toList();
  }

  Future<int> deletarEncomenda(int id) async {
    final db = await instance.database;
    return await db.delete('encomendas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> atualizarStatus(int id, String novoStatus) async {
    final db = await instance.database;
    return await db.update(
      'encomendas',
      {'status': novoStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> atualizarRemoteId(Encomenda encomenda) async {
  final db = await database;
  return await db.update(
    'encomendas',
    {'remoteId': encomenda.remoteId},
    where: 'id = ?',
    whereArgs: [encomenda.id],
  );
}


  Future<List<Encomenda>> getUnsyncedEncomendas() async {
    final db = await instance.database;
    final result =
        await db.query('encomendas', where: 'syncStatus = ?', whereArgs: [0]);
    return result.map((json) => Encomenda.fromJson(json)).toList();
  }

  Future<int> markEncomendaSynced(int id, int remoteId) async {
    final db = await instance.database;
    return await db.update(
      'encomendas',
      {
        'syncStatus': 1, // Marca como sincronizado
        'remoteId': remoteId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Encomenda?> getEncomendaByRemoteId(int remoteId) async {
    final db = await instance.database;
    final result = await db
        .query('encomendas', where: 'remoteId = ?', whereArgs: [remoteId]);
    if (result.isNotEmpty) {
      return Encomenda.fromJson(result.first);
    }
    return null;
  }

  Future<int> insertFromRemote(Map<String, dynamic> json) async {
    final db = await instance.database;
    return await db.insert(
      'encomendas',
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}
