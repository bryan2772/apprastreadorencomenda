import 'package:flutter/material.dart'; // Importa o pacote Flutter Material Design

class AddEncomendaScreen extends StatefulWidget {
  // A classe AddEncomendaScreen é um StatefulWidget, pois precisa manter o estado dos campos do formulário.
  @override
  _AddEncomendaScreenState createState() => _AddEncomendaScreenState();
}

class _AddEncomendaScreenState extends State<AddEncomendaScreen> {
  // Chave global para o formulário, usada para validação e gerenciamento do estado do formulário.
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto do formulário.
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _codigoRastreioController = TextEditingController();
  final TextEditingController _transportadoraController = TextEditingController();

  // Método para salvar a encomenda.
  void _salvarEncomenda() {
    if (_formKey.currentState!.validate()) {
      // Se o formulário for válido, podemos prosseguir com a lógica de salvar a encomenda.
      // Aqui futuramente vamos salvar a encomenda no banco de dados ou em uma lista.
      Navigator.pop(context); // Fecha a tela após salvar
    }
  }

  @override
  Widget build(BuildContext context) {
    // O método build é responsável por construir a interface do usuário.
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Encomenda'), // Título da AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adiciona um padding ao redor do formulário
        child: Form(
          key: _formKey, // Associa a chave do formulário
          child: Column(
            children: [
              // Campo de texto para o nome da encomenda
              TextFormField(
                controller: _nomeController, // Controlador para o campo de texto
                decoration: InputDecoration(labelText: 'Nome da Encomenda'), // Rótulo do campo
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null, // Validação do campo
              ),
              // Campo de texto para o código de rastreamento
              TextFormField(
                controller: _codigoRastreioController, // Controlador para o campo de texto
                decoration: InputDecoration(labelText: 'Código de Rastreamento'), // Rótulo do campo
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null, // Validação do campo
              ),
              // Campo de texto para a transportadora
              TextFormField(
                controller: _transportadoraController, // Controlador para o campo de texto
                decoration: InputDecoration(labelText: 'Transportadora'), // Rótulo do campo
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null, // Validação do campo
              ),
              SizedBox(height: 20), // Espaçamento entre os campos e o botão
              // Botão para salvar a encomenda
              ElevatedButton(
                onPressed: _salvarEncomenda, // Ação ao pressionar o botão
                child: Text('Salvar'), // Texto do botão
              ),
            ],
          ),
        ),
      ),
    );
  }
}