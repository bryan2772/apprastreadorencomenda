import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/tracking_service.dart';
import '../services/database_helper.dart';

class DetalhesEncomendaScreen extends StatefulWidget {
  final Encomenda encomenda;
  const DetalhesEncomendaScreen({required this.encomenda,super.key});

  @override
  DetalhesEncomendaScreenState createState() => DetalhesEncomendaScreenState();
}

class DetalhesEncomendaScreenState extends State<DetalhesEncomendaScreen> {
  bool _isUpdating = false;
  late Encomenda _encomenda; // Cópia local da encomenda para permitir atualizações
  List<dynamic> _eventos = []; // Lista de eventos de rastreamento

  @override
  void initState() {
    super.initState();
    _encomenda = widget.encomenda; // Inicializa a cópia local
    _carregarEventos(); // Carrega os eventos ao iniciar a tela
  }

  Future<void> _carregarEventos() async {
    try {
      final trackingService = TrackingService();
      final dados = await trackingService.buscarStatus(_encomenda.codigoRastreio);

      // Extrair a lista de eventos da resposta
      setState(() {
        _eventos = dados['eventos'] ?? [];
      });
    } catch (e) {
      if (!mounted) return; // Verifica se o widget ainda está na árvore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar eventos: $e')),
      );
    }
  }

  Future<void> _atualizarStatus() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final trackingService = TrackingService();
      final dados = await trackingService.buscarStatus(_encomenda.codigoRastreio);

      // Extrair o status mais recente da lista de eventos
      final eventos = dados['eventos'] as List<dynamic>;
      if (eventos.isNotEmpty) {
        final ultimoEvento = eventos.first;
        final novoStatus = ultimoEvento['status'] ?? _encomenda.status;

        // Atualizar no banco de dados
        await DatabaseHelper.instance.atualizarStatus(_encomenda.id!, novoStatus);

        // Atualizar o estado local
        setState(() {
          _encomenda.status = novoStatus;
          _eventos = eventos; // Atualiza a lista de eventos
        });

        // Mostra uma mensagem de sucesso
        if (!mounted) return; // Verifica se o widget ainda está na árvore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado para "$novoStatus"')),
        );
      } else {
        if (!mounted) return; // Verifica se o widget ainda está na árvore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhum evento encontrado para este código de rastreio.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_encomenda.nome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações básicas da encomenda
            Text("Código: ${_encomenda.codigoRastreio}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Transportadora: ${_encomenda.transportadora}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Status: ${_encomenda.status}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Data de Criação: ${_encomenda.dataCriacao}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // Botão para atualizar o status
            _isUpdating
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _atualizarStatus,
                    child: Text('Atualizar Status'),
                  ),

            SizedBox(height: 20),

            // Título da lista de eventos
            Text(
              "Histórico de Eventos:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Lista de eventos de rastreamento
            Expanded(
              child: _eventos.isEmpty
                  ? Center(
                      child: Text(
                        "Nenhum evento encontrado.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _eventos.length,
                      itemBuilder: (context, index) {
                        final evento = _eventos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(evento['status'] ?? 'Sem status'),
                            subtitle: Text(
                              "${evento['data']} ${evento['hora']}\n${evento['local']}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}