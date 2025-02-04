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
    version: 1,
    onCreate: _createDB,
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
        dataCriacao TEXT NOT NULL
      )
    ''');
  }

  Future<int> inserirEncomenda(Encomenda encomenda) async {
    final db = await instance.database;
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
