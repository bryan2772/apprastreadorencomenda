import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/database_helper.dart';
import 'add_encomenda_screen.dart';
import 'detalhes_encomenda_screen.dart'; // Adicione esta linha

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Agora usa o super parameter diretamente

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Encomenda> _encomendas = [];

  @override
  void initState() {
    super.initState();
    _carregarEncomendas();
  }

  Future<void> _carregarEncomendas() async {
    final encomendas = await DatabaseHelper.instance.listarEncomendas();
    setState(() {
      _encomendas = encomendas;
    });
  }

  Future<void> _adicionarEncomenda() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEncomendaScreen()),
    );

    if (resultado == true) {
      _carregarEncomendas();
    }
  }

  void _deletarEncomenda(int id) async {
    await DatabaseHelper.instance.deletarEncomenda(id);
    _carregarEncomendas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Encomendas')),
      body: _encomendas.isEmpty
          ? Center(child: Text('Nenhuma encomenda cadastrada.'))
          : ListView.builder(
              itemCount: _encomendas.length,
              itemBuilder: (context, index) {
                final encomenda = _encomendas[index];
                return ListTile(
                  title: Text(encomenda.nome),
                  subtitle: Text('Código: ${encomenda.codigoRastreio}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletarEncomenda(encomenda.id!),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetalhesEncomendaScreen(encomenda: encomenda)),
                    ).then((_) {
                      _carregarEncomendas(); // Recarrega a lista ao voltar da tela de detalhes
                    });
                  },
                );

              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarEncomenda,
        child: Icon(Icons.add),
      ),
    );
  }
}
