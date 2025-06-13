class Receipt {
  final int id;
  final int idCliente;
  final int idServico;
  final String data;
  final String horario;
  final String nomeCliente;
  final String emailCliente;
  final String cpfCliente;
  final String telefoneCliente;
  final String nomeFuncionario;
  final String nomeServico;
  final double precoServico;
  final String duracaoServico;
  final String categoriaServico;
  final String nomeEmpresa;
  final int idEmpresa;
  final int idPrestacao;
  final String statusPrestacao;
  final String pagamentoPrestacao;
  final String? inicioPrestacao;
  final String? terminoPrestacao;

  Receipt({
    required this.id,
    required this.idCliente,
    required this.idServico,
    required this.data,
    required this.horario,
    required this.nomeCliente,
    required this.emailCliente,
    required this.cpfCliente,
    required this.telefoneCliente,
    required this.nomeFuncionario,
    required this.nomeServico,
    required this.precoServico,
    required this.duracaoServico,
    required this.categoriaServico,
    required this.nomeEmpresa,
    required this.idEmpresa,
    required this.idPrestacao,
    required this.statusPrestacao,
    required this.pagamentoPrestacao,
    this.inicioPrestacao,
    this.terminoPrestacao,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      idCliente: json['idCliente'],
      idServico: json['idServico'],
      data: json['data'],
      horario: json['horario'],
      nomeCliente: json['nomeCliente'],
      emailCliente: json['emailCliente'],
      cpfCliente: json['cpfCliente'],
      telefoneCliente: json['telefoneCliente'],
      nomeFuncionario: json['nomeFuncionario'],
      nomeServico: json['nomeServico'],
      precoServico: (json['precoServico'] as num).toDouble(),
      duracaoServico: json['duracaoServico'],
      categoriaServico: json['categoriaServico'],
      nomeEmpresa: json['nomeEmpresa'],
      idEmpresa: json['idEmpresa'],
      idPrestacao: json['idPrestacao'],
      statusPrestacao: json['statusPrestacao'],
      pagamentoPrestacao: json['pagamentoPrestacao'],
      inicioPrestacao: json['inicioPrestacao'],
      terminoPrestacao: json['terminoPrestacao'],
    );
  }
}
