import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/database_helper.dart';
import 'add_encomenda_screen.dart';
import 'detalhes_encomenda_screen.dart';
import 'archived_encomendas_screen.dart';

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
    final encomendas =
        await DatabaseHelper.instance.listarEncomendasNaoArquivadas();
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

  void _arquivarEncomenda(int id) async {
    await DatabaseHelper.instance.arquivarEncomenda(id);
    _carregarEncomendas();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Encomenda arquivada!')),
    );
  }

  Future<bool> _confirmarExclusao(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
            'Tem certeza que deseja excluir esta encomenda? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      _deletarEncomenda(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encomenda excluída!')),
      );
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalEmTransito = _encomendas
        .where((e) => e.status.toLowerCase().contains('trânsito'))
        .length;
    final totalEntregues = _encomendas
        .where((e) => e.status.toLowerCase().contains('entregue'))
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
            color: const Color.fromARGB(255, 255, 255, 255),
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
              title: const Text('Arquivados'),
              leading: const Icon(Icons.archive),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ArchivedEncomendasScreen()),
                );
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
                      direction: DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Excluir',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.orange,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Arquivar',
                                style: TextStyle(color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.archive, color: Colors.white),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          return await _confirmarExclusao(encomenda.id!);
                        } else {
                          _arquivarEncomenda(encomenda.id!);
                          return false;
                        }
                      },
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
                            'Código: ${encomenda.codigoRastreio}\nStatus: ${encomenda.status}',
                            style: TextStyle(
                                color: Colors.grey.shade700, height: 1.4),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon:
                                const Icon(Icons.more_vert, color: Colors.grey),
                            onSelected: (value) {
                              if (value == 'arquivar') {
                                _arquivarEncomenda(encomenda.id!);
                              } else if (value == 'excluir') {
                                _confirmarExclusao(encomenda.id!);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'arquivar',
                                child: Row(
                                  children: [
                                    Icon(Icons.archive, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Arquivar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'excluir',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Excluir'),
                                  ],
                                ),
                              ),
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
            color: Color.fromARGB(255, 255, 255, 255),
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
              backgroundColor: color.withValues(alpha: 0.2),
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
