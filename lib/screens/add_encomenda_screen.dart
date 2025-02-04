import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/database_helper.dart';

class AddEncomendaScreen extends StatefulWidget {
  @override
  _AddEncomendaScreenState createState() => _AddEncomendaScreenState();
}

class _AddEncomendaScreenState extends State<AddEncomendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _codigoRastreioController = TextEditingController();
  final TextEditingController _transportadoraController = TextEditingController();

  void _salvarEncomenda() async {
    if (_formKey.currentState!.validate()) {
      final novaEncomenda = Encomenda(
        id: DateTime.now().millisecondsSinceEpoch, 
        nome: _nomeController.text,
        codigoRastreio: _codigoRastreioController.text,
        transportadora: _transportadoraController.text,
        status: "Aguardando atualização",
        dataCriacao: DateTime.now().toIso8601String(), // Converte para String
      );

      await DatabaseHelper.instance.inserirEncomenda(novaEncomenda);
      Navigator.pop(context, true); // Fecha a tela e retorna "true" para indicar atualização
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
              ElevatedButton(
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
