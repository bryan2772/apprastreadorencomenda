import 'package:flutter/material.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Configuração para desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    // Configuração para Android e iOS (sqflite padrão)
    databaseFactory = databaseFactory;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Usando o parâmetro 'key' diretamente no super

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rastreamento de Encomendas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
