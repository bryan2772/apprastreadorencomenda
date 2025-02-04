import 'dart:convert';
import 'package:http/http.dart' as http;

class TrackingService {
  // Exemplo de endpoint fake. Você pode trocar pela API que escolher.
  //final String _baseUrl = 'https://api.exemplo.com/rastreamento';

  Future<Map<String, dynamic>> buscarStatus(String codigoRastreio) async {
    await Future.delayed(Duration(seconds: 2)); // Simula o tempo de resposta da API
    return {
      "codigoRastreio": codigoRastreio,
      "status": "Enviado",
      "ultimaAtualizacao": DateTime.now().toIso8601String(),
    };
  }
/*
  Future<Map<String, dynamic>> buscarStatus(String codigoRastreio) async {
    // Montando a URL com o código de rastreamento.
    final url = Uri.parse('$_baseUrl/$codigoRastreio');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Se a API não retornar status 200, lança um erro.
        throw Exception('Falha ao buscar status. Código: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }*/
}
