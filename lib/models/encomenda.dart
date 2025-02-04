class Encomenda {
  final int? id;
  final String nome;
  final String codigoRastreio;
  final String transportadora;
  String status; // Agora não é final
  final String dataCriacao;

  Encomenda({
    this.id,
    required this.nome,
    required this.codigoRastreio,
    required this.transportadora,
    required this.status,
    required this.dataCriacao,
  });


  // Método factory para criar uma instância de Encomenda a partir de um JSON
  factory Encomenda.fromJson(Map<String, dynamic> json) {
    return Encomenda(
      id: json['id'] as int?, // Garante que o ID seja tratado como int
      nome: json['nome'],
      codigoRastreio: json['codigoRastreio'],
      transportadora: json['transportadora'],
      status: json['status'],
      dataCriacao: json['dataCriacao'],
    );
  }

  // Método para converter uma instância de Encomenda em um JSON para o banco de dados
  Map<String, dynamic> toJson() {
    return {
      'id': id, // O SQLite gerará automaticamente um ID se ele for nulo
      'nome': nome,
      'codigoRastreio': codigoRastreio,
      'transportadora': transportadora,
      'status': status,
      'dataCriacao': dataCriacao,
    };
  }
}
