class Employee {
  final int id;
  final String cpf;
  final String nome;
  final String email;
  final String telefone;
  final String dataNasc;
  final String cargo;
  final String empresa;

  Employee({
    required this.id,
    required this.cpf,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.dataNasc,
    required this.cargo,
    required this.empresa,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      cpf: json['cpf'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      dataNasc: json['data_nasc'],
      cargo: json['cargo'],
      empresa: json['empresa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cpf': cpf,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'dataNasc': dataNasc,
      'cargo': cargo,
      'empresa': empresa,
    };
  }
}
