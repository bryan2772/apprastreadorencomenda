import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/database_helper.dart';
import 'add_encomenda_screen.dart';
import 'detalhes_encomenda_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  void _abrirDetalhes(Encomenda encomenda) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesEncomendaScreen(encomenda: encomenda),
      ),
    );
    _carregarEncomendas();
  }

  void _deletarEncomenda(int id) async {
    await DatabaseHelper.instance.deletarEncomenda(id);
    _carregarEncomendas();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalEmTransito = _encomendas
        .where((e) => e.status?.toLowerCase().contains('trânsito') ?? false)
        .length;
    final totalEntregues = _encomendas
        .where((e) => e.status?.toLowerCase().contains('entregue') ?? false)
        .length;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'Minhas Encomendas',
          style: theme.textTheme.titleLarge?.copyWith(
            color:
                const Color.fromARGB(255, 255, 255, 255), // Adicione esta linha
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('notificaçoes ativas')));
            },
          ),
        ],
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Configuraçoes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('arquivados'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _carregarEncomendas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cards de resumo
              Row(
                children: [
                  Expanded(
                    child: _ResumoCard(
                      icon: Icons.local_shipping,
                      label: 'Em trânsito',
                      value: totalEmTransito.toString(),
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResumoCard(
                      icon: Icons.done_all,
                      label: 'Entregues',
                      value: totalEntregues.toString(),
                      color: Colors.greenAccent.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Últimas encomendas',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (_encomendas.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Text(
                      'Nenhuma encomenda cadastrada.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Column(
                  children: _encomendas.map((encomenda) {
                    return Dismissible(
                      key: Key(encomenda.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deletarEncomenda(encomenda.id!),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade100,
                            child: const Icon(Icons.local_mall,
                                color: Colors.deepPurple),
                          ),
                          title: Text(
                            encomenda.nome,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Código: ${encomenda.codigoRastreio}\nStatus: ${encomenda.status ?? 'Desconhecido'}',
                            style: TextStyle(
                                color: Colors.grey.shade700, height: 1.4),
                          ),
                          // CORREÇÃO: Removido o trailing duplicado
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deletarEncomenda(encomenda.id!),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          onTap: () => _abrirDetalhes(encomenda),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarEncomenda,
        backgroundColor: Colors.deepPurple,
        label: const Text(
          'Adicionar',
          style: TextStyle(
            color: Color.fromARGB(
                255, 255, 255, 255), // Já está cinza, mas pode alterar
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}

// Classe auxiliar movida para fora ou mantida como interna
class _ResumoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResumoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
