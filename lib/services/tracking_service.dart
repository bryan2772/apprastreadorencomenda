import 'dart:convert';
import 'package:http/http.dart' as http;

class TrackingService {
  // URL base da API do Linketrack
  final String _baseUrl = 'https://api.linketrack.com/track/json';

  // Dados de autenticação (substitua pelo seu usuário e token)
  final String _user = 'teste'; // Substitua pelo seu usuário
  final String _token = '1abcd00b2731640e886fb41a8a9671ad1434c599dbaa0a0de9a5aa619f29a83f'; // Substitua pelo seu token

  // Método para buscar o status de rastreamento
  Future<Map<String, dynamic>> buscarStatus(String codigoRastreio) async {
    // Montando a URL com os parâmetros necessários
    final url = Uri.parse('$_baseUrl?user=$_user&token=$_token&codigo=$codigoRastreio');

    try {
      // Fazendo a requisição GET
      final response = await http.get(url);

      // Verificando se a requisição foi bem-sucedida (status code 200)
      if (response.statusCode == 200) {
        // Decodificando o JSON da resposta
        return jsonDecode(response.body);
      } else {
        // Se a API não retornar status 200, lança um erro.
        throw Exception('Falha ao buscar status. Código: ${response.statusCode}');
      }
    } catch (e) {
      // Captura erros de conexão ou outros problemas
      throw Exception('Erro na requisição: $e');
    }
  }
  /*Future<Map<String, dynamic>> buscarStatus(String codigoRastreio) async {
    await Future.delayed(Duration(seconds: 2)); // Simula o tempo de resposta da API
    return {
      "codigoRastreio": codigoRastreio,
      "status": "Enviado",
      "ultimaAtualizacao": DateTime.now().toIso8601String(),
    };
  }*/
}

