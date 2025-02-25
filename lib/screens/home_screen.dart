import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/database_helper.dart';
import 'add_encomenda_screen.dart';
import 'detalhes_encomenda_screen.dart';
import '../services/sync_service.dart';
import '../services/api_service.dart'; // Certifique-se de ter esse arquivo

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final SyncService _syncService = SyncService();
  final ApiService _apiService = ApiService(); // Instância do ApiService
  List<Encomenda> _encomendas = [];

  @override
  void initState() {
    super.initState();
    _carregarEncomendas();
    _iniciarSincronizacao();
  }

  Future<void> _carregarEncomendas() async {
    final encomendas = await DatabaseHelper.instance.listarEncomendas();
    setState(() {
      _encomendas = encomendas;
    });
  }

  void _iniciarSincronizacao() async {
    // Verifica a conexão com a internet, se necessário, e sincroniza
    await _syncService.syncEncomendas();
    _carregarEncomendas();
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

  void _deletarEncomenda(Encomenda encomenda) async {
  try {
    // Se a encomenda foi sincronizada com o servidor, tenta excluir remotamente
    if (encomenda.remoteId != null) {
      await _apiService.deletarEncomenda(encomenda.remoteId!);
    }
    // Exclui localmente
    await DatabaseHelper.instance.deletarEncomenda(encomenda.id!);
    _carregarEncomendas();
  } catch (e) {
    // Verifica se o erro é um 404
    if (e.toString().contains("404")) {
      // A encomenda não existe mais no servidor, então exclua localmente também
      await DatabaseHelper.instance.deletarEncomenda(encomenda.id!);
      if (!mounted) return; // 🔍 Verifica se o widget ainda está na árvore antes de usar o contexto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Encomenda excluída localmente, pois não foi encontrada no servidor.')),
      );
      _carregarEncomendas();
    } else {
      if (!mounted) return; // 🔍 Verifica se o widget ainda está na árvore antes de usar o contexto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir encomenda: $e')),
      );
    }
  }
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
        title: const Text('Minhas Encomendas'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificações ativas')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 176, 163, 207)),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Arquivados'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _encomendas.isEmpty
          ? const Center(child: Text('Nenhuma encomenda cadastrada.'))
          : ListView.builder(
              itemCount: _encomendas.length,
              itemBuilder: (context, index) {
                final encomenda = _encomendas[index];
                return ListTile(
                  title: Text(encomenda.nome),
                  subtitle:
                      Text('Código: ${encomenda.codigoRastreio}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    // Passe a instância inteira de Encomenda para a função de exclusão
                    onPressed: () => _deletarEncomenda(encomenda),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetalhesEncomendaScreen(encomenda: encomenda),
                      ),
                    ).then((_) {
                      _carregarEncomendas(); // Recarrega a lista ao voltar da tela de detalhes
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarEncomenda,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
