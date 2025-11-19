import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/database_helper.dart';
import 'detalhes_encomenda_screen.dart';

class ArchivedEncomendasScreen extends StatefulWidget {
  const ArchivedEncomendasScreen({super.key});

  @override
  ArchivedEncomendasScreenState createState() =>
      ArchivedEncomendasScreenState();
}

class ArchivedEncomendasScreenState extends State<ArchivedEncomendasScreen> {
  List<Encomenda> _encomendasArquivadas = [];

  @override
  void initState() {
    super.initState();
    _carregarEncomendasArquivadas();
  }

  Future<void> _carregarEncomendasArquivadas() async {
    final encomendas =
        await DatabaseHelper.instance.listarEncomendasArquivadas();
    setState(() {
      _encomendasArquivadas = encomendas;
    });
  }

  void _desarquivarEncomenda(int id) async {
    await DatabaseHelper.instance.desarquivarEncomenda(id);
    _carregarEncomendasArquivadas();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Encomenda desarquivada!')),
    );
  }

  void _deletarEncomenda(int id) async {
    bool confirmado = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
            'Tem certeza que deseja excluir esta encomenda permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await DatabaseHelper.instance.deletarEncomenda(id);
      _carregarEncomendasArquivadas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encomenda excluída permanentemente!')),
      );
    }
  }

  void _abrirDetalhes(Encomenda encomenda) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesEncomendaScreen(encomenda: encomenda),
      ),
    );
    _carregarEncomendasArquivadas();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encomendas Arquivadas'),
        backgroundColor: Colors.grey[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _carregarEncomendasArquivadas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Encomendas Arquivadas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Encomendas arquivadas não aparecem na tela principal e não são contabilizadas nos resumos.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              if (_encomendasArquivadas.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Column(
                      children: [
                        Icon(Icons.archive_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma encomenda arquivada.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _encomendasArquivadas.map((encomenda) {
                    return Dismissible(
                      key: Key('archived_${encomenda.id}'),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.green,
                        child: const Row(
                          children: [
                            Icon(Icons.unarchive, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Desarquivar',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Excluir',
                                style: TextStyle(color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.delete_forever, color: Colors.white),
                          ],
                        ),
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          _desarquivarEncomenda(encomenda.id!);
                        } else {
                          _deletarEncomenda(encomenda.id!);
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child:
                                const Icon(Icons.archive, color: Colors.grey),
                          ),
                          title: Text(
                            encomenda.nome,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Código: ${encomenda.codigoRastreio}\nStatus: ${encomenda.status}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.unarchive,
                                    color: Colors.green),
                                onPressed: () =>
                                    _desarquivarEncomenda(encomenda.id!),
                                tooltip: 'Desarquivar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever,
                                    color: Colors.red),
                                onPressed: () =>
                                    _deletarEncomenda(encomenda.id!),
                                tooltip: 'Excluir permanentemente',
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
    );
  }
}
