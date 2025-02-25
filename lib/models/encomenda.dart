class Encomenda {
  final int? id;
  final String nome;
  final String codigoRastreio;
  final String transportadora;
  String status; // se precisar ser mutável
  final String dataCriacao;
  int? remoteId;  // Adicione essa propriedade

  Encomenda({
    this.id,
    required this.nome,
    required this.codigoRastreio,
    required this.transportadora,
    required this.status,
    required this.dataCriacao,
    this.remoteId, // pode ser nulo se ainda não sincronizado
  });

  factory Encomenda.fromJson(Map<String, dynamic> json) {
    return Encomenda(
      id: json['id'] as int?,
      nome: json['nome'],
      codigoRastreio: json['codigoRastreio'],
      transportadora: json['transportadora'],
      status: json['status'],
      dataCriacao: json['dataCriacao'],
      remoteId: json['remoteId'] as int?, // Lê o remoteId, se existir
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'codigoRastreio': codigoRastreio,
      'transportadora': transportadora,
      'status': status,
      'dataCriacao': dataCriacao,
      'remoteId': remoteId, // Inclui o remoteId no JSON
    };
  }
}
