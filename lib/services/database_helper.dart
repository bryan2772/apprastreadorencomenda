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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Adicione esta linha
    );
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
        arquivada INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

// E adicione o método onUpgrade:
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE encomendas ADD COLUMN arquivada INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<int> inserirEncomenda(Encomenda encomenda) async {
    final db = await instance.database;
    //await Future.delayed(Duration(seconds: 80));
    return await db.insert(
      'encomendas',
      encomenda.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Evita erros de duplicação
    );
  }

  Future<List<Encomenda>> listarEncomendas() async {
    final db = await instance.database;
    final result = await db.query('encomendas');
    return result.map((json) => Encomenda.fromJson(json)).toList();
  }

// Listar encomendas não arquivadas (para a tela principal)
  Future<List<Encomenda>> listarEncomendasNaoArquivadas() async {
    final db = await database;
    final result = await db.query(
      'encomendas',
      where: 'arquivada = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
    );
    return result.map((json) => Encomenda.fromJson(json)).toList();
  }

  // Método para arquivar uma encomenda
  Future<int> arquivarEncomenda(int id) async {
    final db = await database;
    return await db.update(
      'encomendas',
      {'arquivada': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Listar encomendas arquivadas
  Future<List<Encomenda>> listarEncomendasArquivadas() async {
    final db = await database;
    final result = await db.query(
      'encomendas',
      where: 'arquivada = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );
    return result.map((json) => Encomenda.fromJson(json)).toList();
  }

  // Método para desarquivar uma encomenda
  Future<int> desarquivarEncomenda(int id) async {
    final db = await database;
    return await db.update(
      'encomendas',
      {'arquivada': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
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
}
