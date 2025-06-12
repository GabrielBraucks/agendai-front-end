class Scheduling {
  final int id;
  final int idCliente;
  final int idServico;
  final String data;
  final String inicio;
  final String fim;
  final String horario;
  final String nomeServico;
  final String duracao;
  final String nomeEmpresa;
  final String nomeFuncionario;
  final String nomeCliente;
  final int idEmpresa;

  Scheduling({
    required this.id,
    required this.idCliente,
    required this.idServico,
    required this.data,
    required this.horario,
    required this.inicio,
    required this.fim,
    required this.nomeServico,
    required this.duracao,
    required this.nomeEmpresa,
    required this.idEmpresa,
    required this.nomeCliente,
    required this.nomeFuncionario,
  });

  factory Scheduling.fromJson(Map<String, dynamic> json) {
    return Scheduling(
      id: json['id'],
      idCliente: json['idCliente'],
      idServico: json['idServico'],
      data: json['data'],
      horario: json['horario'],
      inicio: json['inicio'],
      fim: json['fim'],
      nomeServico: json['nomeServico'],
      nomeCliente: json['nomeCliente'],
      duracao: json['duracao'],
      nomeEmpresa: json['nomeEmpresa'],
      idEmpresa: json['idEmpresa'],
      nomeFuncionario: json['nomeFuncionario'],
    );
  }
}
