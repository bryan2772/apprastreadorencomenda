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
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('Minhas Encomendas'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('notificaçoes ativas')));
            },
          ), 
        ],  
      ),
  
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 176, 163, 207)),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                // Update the state of the app.
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Configuraçoes'),
              onTap: () {
                // Update the state of the app.
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('arquivados'),
              onTap: () {
                // Update the state of the app.
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

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
        //backgroundColor: Colors.red,
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
      
    );
  }
}
