import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/tracking_service.dart';
import '../services/database_helper.dart';

class DetalhesEncomendaScreen extends StatefulWidget {
  final Encomenda encomenda;

  DetalhesEncomendaScreen({required this.encomenda});

  @override
  _DetalhesEncomendaScreenState createState() => _DetalhesEncomendaScreenState();
}

class _DetalhesEncomendaScreenState extends State<DetalhesEncomendaScreen> {
  bool _isUpdating = false;

  Future<void> _atualizarStatus() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final trackingService = TrackingService();
      final dados = await trackingService.buscarStatus(widget.encomenda.codigoRastreio);

      // Extrair o novo status da resposta
      final novoStatus = dados['status'] ?? widget.encomenda.status;

      // Atualizar no banco de dados
      await DatabaseHelper.instance.atualizarStatus(widget.encomenda.id!, novoStatus);

      // Mostra uma mensagem de sucesso e atualiza o estado local
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para "$novoStatus"')),
      );
      setState(() {
        widget.encomenda.status = novoStatus;
      });
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
        title: Text(widget.encomenda.nome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Código: ${widget.encomenda.codigoRastreio}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Transportadora: ${widget.encomenda.transportadora}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Status: ${widget.encomenda.status}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Data de Criação: ${widget.encomenda.dataCriacao}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            _isUpdating
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _atualizarStatus,
                    child: Text('Atualizar Status'),
                  ),
          ],
        ),
      ),
    );
  }
}
