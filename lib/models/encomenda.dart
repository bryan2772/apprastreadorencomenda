class Encomenda {
  // Atributos da classe Encomenda
  final String id; // Identificador único da encomenda
  final String nome; // Nome da encomenda
  final String codigoRastreio; // Código de rastreio da encomenda
  final String transportadora; // Nome da transportadora responsável pela entrega
  final String status; // Status atual da encomenda (ex: "Em trânsito", "Entregue")
  final DateTime dataCriacao; // Data de criação da encomenda

  // Construtor da classe Encomenda
  Encomenda({
    required this.id, // Obrigatório passar o ID
    required this.nome, // Obrigatório passar o nome
    required this.codigoRastreio, // Obrigatório passar o código de rastreio
    required this.transportadora, // Obrigatório passar a transportadora
    required this.status, // Obrigatório passar o status
    required this.dataCriacao, // Obrigatório passar a data de criação
  });

  // Método factory para criar uma instância de Encomenda a partir de um JSON
  factory Encomenda.fromJson(Map<String, dynamic> json) {
    return Encomenda(
      id: json['id'], // Extrai o ID do JSON
      nome: json['nome'], // Extrai o nome do JSON
      codigoRastreio: json['codigoRastreio'], // Extrai o código de rastreio do JSON
      transportadora: json['transportadora'], // Extrai a transportadora do JSON
      status: json['status'], // Extrai o status do JSON
      dataCriacao: DateTime.parse(json['dataCriacao']), // Converte a string de data para DateTime
    );
  }

  // Método para converter a instância de Encomenda para um JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Inclui o ID no JSON
      'nome': nome, // Inclui o nome no JSON
      'codigoRastreio': codigoRastreio, // Inclui o código de rastreio no JSON
      'transportadora': transportadora, // Inclui a transportadora no JSON
      'status': status, // Inclui o status no JSON
      'dataCriacao': dataCriacao.toIso8601String(), // Converte a data para uma string no formato ISO 8601
    };
  }
}