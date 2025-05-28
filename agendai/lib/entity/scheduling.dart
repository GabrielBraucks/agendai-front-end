class Scheduling {
  final int id;
  final int idCliente;
  final int idServico;
  final String data;
  final String horario;
  final String nomeServico;
  final String duracao;
  final String nomeEmpresa;
  final int idEmpresa;
  final String nomeCliente;

  Scheduling({
    required this.id,
    required this.idCliente,
    required this.idServico,
    required this.data,
    required this.horario,
    required this.nomeServico,
    required this.duracao,
    required this.nomeEmpresa,
    required this.nomeCliente,
    required this.idEmpresa,
  });

  factory Scheduling.fromJson(Map<String, dynamic> json) {
    return Scheduling(
      id: json['id'],
      idCliente: json['idCliente'],
      idServico: json['idServico'],
      nomeCliente: json['nomeCliente'],
      data: json['data'],
      horario: json['horario'],
      nomeServico: json['nomeServico'],
      duracao: json['duracao'],
      nomeEmpresa: json['nomeEmpresa'],
      idEmpresa: json['idEmpresa'],
    );
  }
}
