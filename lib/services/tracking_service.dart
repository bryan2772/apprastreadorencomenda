import 'dart:math';

class TrackingService {
  // Mapa para armazenar o estado atual de cada código de rastreio
  final Map<String, int> _estadoAtual = {};
  final Random _random = Random();

  // Lista de possíveis estados com suas probabilidades
  final List<EstadoRastreio> _estados = [
    EstadoRastreio(
        status: 'Objeto registrado',
        probabilidade: 0.1, // 10% de chance
        eventos: [
          {
            "status": "Objeto registrado",
            "data": "2024-01-14",
            "hora": "14:20",
            "local": "Agência - São Paulo"
          }
        ]),
    EstadoRastreio(
        status: 'Postado',
        probabilidade: 0.2, // 20% de chance
        eventos: [
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
        ]),
    EstadoRastreio(
        status: 'Em trânsito - Centro de Distribuição',
        probabilidade: 0.3, // 30% de chance
        eventos: [
          {
            "status": "Em trânsito - Centro de Distribuição",
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
        ]),
    EstadoRastreio(
        status: 'Em trânsito - Saiu para entrega',
        probabilidade: 0.25, // 25% de chance
        eventos: [
          {
            "status": "Saiu para entrega",
            "data": "2024-01-16",
            "hora": "08:15",
            "local": "Unidade Local - Rio de Janeiro"
          },
          {
            "status": "Em trânsito - Centro de Distribuição",
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
        ]),
    EstadoRastreio(
        status: 'Entregue',
        probabilidade: 0.15, // 15% de chance
        eventos: [
          {
            "status": "Entregue",
            "data": "2024-01-16",
            "hora": "14:30",
            "local": "Residência - Rio de Janeiro"
          },
          {
            "status": "Saiu para entrega",
            "data": "2024-01-16",
            "hora": "08:15",
            "local": "Unidade Local - Rio de Janeiro"
          },
          {
            "status": "Em trânsito - Centro de Distribuição",
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
        ]),
  ];

  Future<Map<String, dynamic>> buscarStatus(String codigoRastreio) async {
    await Future.delayed(Duration(seconds: 2)); // Simula tempo de resposta

    // Se é a primeira vez que este código é consultado, define um estado inicial
    if (!_estadoAtual.containsKey(codigoRastreio)) {
      _estadoAtual[codigoRastreio] = _definirEstadoInicial();
    } else {
      // Avança o estado (com alguma aleatoriedade)
      _estadoAtual[codigoRastreio] =
          _avancarEstado(_estadoAtual[codigoRastreio]!);
    }

    final estadoIndex = _estadoAtual[codigoRastreio]!;
    final estado = _estados[estadoIndex];

    // Gera datas realistas baseadas no estado atual
    final eventosComDatas = _gerarDatasRealistas(estado.eventos, estadoIndex);

    return {
      "codigoRastreio": codigoRastreio,
      "status": estado.status,
      "ultimaAtualizacao": DateTime.now().toIso8601String(),
      "eventos": eventosComDatas,
    };
  }

  int _definirEstadoInicial() {
    final chance = _random.nextDouble();

    double acumulado = 0;
    for (int i = 0; i < _estados.length; i++) {
      acumulado += _estados[i].probabilidade;
      if (chance <= acumulado) {
        return i;
      }
    }

    return 0; // Fallback
  }

  int _avancarEstado(int estadoAtual) {
    // Chance de avançar para o próximo estado
    if (estadoAtual < _estados.length - 1 && _random.nextDouble() < 0.6) {
      return estadoAtual + 1;
    }

    // Chance de permanecer no mesmo estado
    return estadoAtual;
  }

  List<Map<String, String>> _gerarDatasRealistas(
      List<Map<String, String>> eventos, int estadoIndex) {
    final agora = DateTime.now();
    final eventosComDatas = <Map<String, String>>[];

    // Quanto mais avançado o estado, mais antigas as datas
    final diasBase = (_estados.length - estadoIndex) * 2;

    for (int i = 0; i < eventos.length; i++) {
      final diasAtras = diasBase + i;
      final dataEvento = agora.subtract(Duration(days: diasAtras));

      eventosComDatas.add({
        ...eventos[i],
        "data": _formatarData(dataEvento),
        "hora": _gerarHoraAleatoria(),
      });
    }

    return eventosComDatas;
  }

  String _formatarData(DateTime data) {
    return '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  }

  String _gerarHoraAleatoria() {
    final hora = _random.nextInt(9) + 8; // Entre 8h e 17h
    final minuto = _random.nextInt(60);
    return '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
  }

  // Método para resetar o estado de um código específico (útil para testes)
  void resetarEstado(String codigoRastreio) {
    _estadoAtual.remove(codigoRastreio);
  }

  // Método para forçar um estado específico (útil para testes)
  void forcarEstado(String codigoRastreio, String status) {
    final index = _estados.indexWhere((estado) => estado.status == status);
    if (index != -1) {
      _estadoAtual[codigoRastreio] = index;
    }
  }

  // Método para debug: ver o estado atual de todos os códigos
  Map<String, String> getEstadosAtuais() {
    final map = <String, String>{};
    _estadoAtual.forEach((codigo, index) {
      map[codigo] = _estados[index].status;
    });
    return map;
  }
}

class EstadoRastreio {
  final String status;
  final double probabilidade;
  final List<Map<String, String>> eventos;

  EstadoRastreio({
    required this.status,
    required this.probabilidade,
    required this.eventos,
  });
}
