class Customer {
  final int id;
  final String nome;
  final String cpf;
  final String email;
  final String telefone;

  Customer({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      nome: json['nome'],
      cpf: json['cpf'],
      email: json['email'],
      telefone: json['telefone'],
    );
  }
}
