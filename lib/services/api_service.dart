import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/encomenda.dart';

class ApiService {
  final String baseUrl = 'http://192.168.15.110:3000';

  Future<List<Encomenda>> listarEncomendas() async {
    final url = Uri.parse('$baseUrl/encomendas');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Encomenda.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar as encomendas');
    }
  }

  Future<int> inserirEncomenda(Encomenda encomenda) async {
    final url = Uri.parse('$baseUrl/encomendas');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(encomenda.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Erro ao inserir encomenda');
    }
  }

  Future<int> atualizarStatus(int id, String novoStatus) async {
    final url = Uri.parse('$baseUrl/encomendas/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': novoStatus}),
    );
    if (response.statusCode == 200) {
      return id;
    } else {
      throw Exception('Erro ao atualizar status');
    }
  }

  Future<void> deletarEncomenda(int remoteId) async {
    final url = Uri.parse('$baseUrl/encomendas/$remoteId');
    final response = await http.delete(url);

    print('Tentando excluir: $url');
    print('Código de status: ${response.statusCode}');
    print('Resposta do servidor: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao excluir encomenda no servidor: ${response.statusCode} - ${response.body}');
    }
  }
}
