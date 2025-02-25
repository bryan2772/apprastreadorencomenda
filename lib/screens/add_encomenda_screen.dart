import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart'; // Importa o ApiService

class AddEncomendaScreen extends StatefulWidget {
  const AddEncomendaScreen({super.key});

  @override
  AddEncomendaScreenState createState() => AddEncomendaScreenState();
}

class AddEncomendaScreenState extends State<AddEncomendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _codigoRastreioController = TextEditingController();
  final TextEditingController _transportadoraController = TextEditingController();
  bool _isUpdating = false;

  final ApiService _apiService = ApiService(); // Instância do serviço da API

  void _salvarEncomenda() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      final novaEncomenda = Encomenda(
        id: DateTime.now().millisecondsSinceEpoch, 
        nome: _nomeController.text,
        codigoRastreio: _codigoRastreioController.text,
        transportadora: _transportadoraController.text,
        status: "Aguardando atualização",
        dataCriacao: DateTime.now().toIso8601String(), // Converte para String
      );

      // 1️⃣ Salva a encomenda localmente primeiro
      int localId = await DatabaseHelper.instance.inserirEncomenda(novaEncomenda);

      // 2️⃣ Tenta enviar a encomenda para o servidor
      try {
        int? remoteId = await _apiService.inserirEncomenda(novaEncomenda);
        
          // 3️⃣ Criar uma nova encomenda com o remoteId atualizado
          final encomendaAtualizada = Encomenda(
            id: localId,
            remoteId: remoteId,
            nome: novaEncomenda.nome,
            codigoRastreio: novaEncomenda.codigoRastreio,
            transportadora: novaEncomenda.transportadora,
            status: novaEncomenda.status,
            dataCriacao: novaEncomenda.dataCriacao,
          );

          await DatabaseHelper.instance.atualizarRemoteId(encomendaAtualizada);
        
      } catch (e) {
        debugPrint("Falha ao sincronizar encomenda com o servidor: $e");
      }

      if (!mounted) return; // Verifica se o widget ainda está na árvore

      Navigator.pop(context, true); // Fecha a tela e retorna "true"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Encomenda')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome da Encomenda'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _codigoRastreioController,
                decoration: InputDecoration(labelText: 'Código de Rastreamento'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _transportadoraController,
                decoration: InputDecoration(labelText: 'Transportadora'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 20),
              _isUpdating
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _salvarEncomenda,
                    child: Text('Salvar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
