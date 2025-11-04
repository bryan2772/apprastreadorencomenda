//import 'dart:convert';
//import 'package:http/http.dart' as http;
//import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:flutter_config/flutter_config.dart';

class TrackingService {
  // URL base da API do Linketrack
  /*
  final String _baseUrl = 'https://api.linketrack.com/track/json';
  final String _user = dotenv.get('LINKETRACK_USER'); // Acessa a variável de ambiente
  final String _token = dotenv.get('LINKETRACK_TOKEN'); // Acessa a variável de ambiente

  // Dados de autenticação (substitua pelo seu usuário e token)
  //final String _user = FlutterConfig.get('LINKETRACK_USER');
  //final String _token = FlutterConfig.get('LINKETRACK_TOKEN');

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
  }*/
  Future<Map<String, dynamic>> buscarStatus(String codigoRastreio) async {
    await Future.delayed(
        Duration(seconds: 2)); // Simula o tempo de resposta da API
    return {
      "codigoRastreio": codigoRastreio,
      "status": "Enviado",
      "ultimaAtualizacao": DateTime.now().toIso8601String(),
      "eventos": [
        // ADICIONE ESTA CHAVE QUE SEU CÓDIGO ESPERA
        {
          "status": "Enviado",
          "data": "2024-01-15",
          "hora": "10:30",
          "local": "Centro de Distribuição - SP"
        },
        {
          "status": "Postado",
          "data": "2024-01-14",
          "hora": "15:45",
          "local": "Agência - São Paulo"
        },
        {
          "status": "Objeto registrado",
          "data": "2024-01-14",
          "hora": "14:20",
          "local": "Agência - São Paulo"
        }
      ]
    };
  }
}
