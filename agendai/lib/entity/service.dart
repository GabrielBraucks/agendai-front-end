class Servico {
  final int id;
  final String nome;
  final double preco;
  final String duracao;
  final String categoria;

  Servico({
    required this.id,
    required this.nome,
    required this.preco,
    required this.duracao,
    required this.categoria,
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'],
      nome: json['nome'],
      preco: (json['preco'] as num).toDouble(),
      duracao: json['duracao'],
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'duracao': duracao,
      'categoria': categoria,
    };
  }
}
