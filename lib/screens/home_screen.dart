import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/add_encomenda_screen.dart'; // Importa o pacote Flutter Material Design

class HomeScreen extends StatelessWidget {
  // A classe HomeScreen é um StatelessWidget, ou seja, não mantém estado interno.
  @override
  Widget build(BuildContext context) {
    // O método build é responsável por construir a interface do usuário.
    return Scaffold(
      // Scaffold é uma estrutura básica de layout do Material Design.
      appBar: AppBar(
        title: Text('Minhas Encomendas'), // Título da AppBar
      ),
      body: Center(
        // O corpo da tela é centralizado.
        child: Text('Nenhuma encomenda cadastrada.'), // Texto exibido quando não há encomendas
      ),
      floatingActionButton: FloatingActionButton(
        // Botão flutuante para adicionar uma nova encomenda
        onPressed: () {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=> AddEncomendaScreen()),
          );
          // Aqui vamos adicionar a lógica para registrar uma nova encomenda
          // Por exemplo, navegar para uma tela de cadastro ou abrir um diálogo.
        },
        child: Icon(Icons.add), // Ícone de "+" dentro do botão
      ),
    );
  }
}