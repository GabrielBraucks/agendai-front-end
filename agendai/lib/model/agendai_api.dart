import 'dart:convert';

import 'package:agendai/entity/customer.dart';
import 'package:agendai/entity/employee.dart';
import 'package:agendai/entity/scheduling.dart';
import 'package:agendai/entity/service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgendaiApi {
  final String baseUrl = 'http://127.0.0.1:3333';

  String? _jwtToken;
  int? _idEnterprise;

  // Getter para o token
  String? get jwtToken => _jwtToken;
  int? get idEnterprise => _idEnterprise;
  AgendaiApi() {
    _loadTokenAndId();
  }
  // Recuperar o token do dispositivo
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  // Salvar o token no dispositivo
  void saveTokenAndId(String token, int idEnterprise) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('id', idEnterprise);

    _jwtToken = token;
    _idEnterprise = idEnterprise;
  }

  // Deletar o token do dispositivo
  Future<void> deleteToken() async {
    _jwtToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> _loadTokenAndId() async {
    _jwtToken = await getToken();
    _idEnterprise = await getId();
  }

  Future<Map<String, String>> _getHeaders() async {
    if (_jwtToken == null) await _loadTokenAndId();
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado. Token JWT não encontrado.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_jwtToken',
    };
  }

  // Login do Usuário
  Future<List> login({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/empresa/login/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': identifier,
        'senha': password,
      }),
    );

    if (response.statusCode <= 299) {
      final responseData = jsonDecode(response.body);
      String jwtToken = responseData['token'];
      print("Bianca $jwtToken");
      int idEnterprise = responseData['empresa']['id'];
      saveTokenAndId(jwtToken, idEnterprise);
      return [jwtToken, idEnterprise];
    }
    return [];
  }

  // Cadastro de Usuário
  Future<bool> register({
    required String employerIdentification,
    required String employername,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/empresa/register/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cnpj': employerIdentification,
        'nome': employername,
        'email': email,
        'senha': password,
      }),
    );
    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Cadastro de Servico
  Future<void> createService({
    required String name,
    required int value,
    required String duration,
    required String category,
  }) async {
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('$baseUrl/servicos/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
      body: jsonEncode({
        'nome': name,
        'preco': value,
        'duracao': duration,
        'categoria': category,
      }),
    );
    if (response.statusCode == 201) {
      print('Serviço criado com sucesso!');
    } else {
      throw Exception('Falha ao criar serviço: ${response.body}');
    }
  }

  // Listar Servicos
  Future<List<Servico>> getServices() async {
    _jwtToken = await getToken();
    _idEnterprise = await getId();
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }
    final url = Uri.parse('$baseUrl/servicos/listarPelaEmpresa/$_idEnterprise');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
    );
    if (response.statusCode == 201) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final responseData =
          jsonResponse.map((servico) => Servico.fromJson(servico)).toList();
      return responseData;
    } else {
      throw Exception('Falha ao listar Servicos: ${response.body}');
    }
  }

  // Deletar Servico
  Future<void> deleteService(int id) async {
    _jwtToken = await getToken();
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }
    final url = Uri.parse('$baseUrl/servicos/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
    );

    if (response.statusCode == 201) {
      print('Serviço deletado com sucesso!');
    } else {
      throw Exception('Falha ao listar Servicos: ${response.body}');
    }
  }

  Future<void> updateEmployee({
    required int id,
    required String name,
    required String cpf,
    required String jobTitle,
    required String email,
    required String celPhone,
    required String birthday,
  }) async {
    _jwtToken = await getToken();
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }
    final url = Uri.parse('$baseUrl/funcionarios/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
      body: jsonEncode({
        "nome": name,
        "cpf": cpf,
        "cargo": jobTitle,
        "email": email,
        "telefone": celPhone,
        "data_nasc": birthday,
      }),
    );

    if (response.statusCode == 201) {
      print('Serviço Atualizado com sucesso!');
    } else {
      throw Exception('Falha ao atualizar Servicos: ${response.body}');
    }
  }

  // Registrar funcionario
  Future<void> createEmployee({
    required String name,
    required String cpf,
    required String jobTitle,
    required String email,
    required String celPhone,
    required String password,
    required String birthday,
  }) async {
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('$baseUrl/funcionarios/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
      body: jsonEncode({
        "nome": name,
        "cpf": cpf,
        "cargo": jobTitle,
        "email": email,
        "telefone": celPhone,
        "senha": password,
        "data_nasc": birthday,
      }),
    );

    print("bianca $response");
    if (response.statusCode == 201) {
      print('Funcionario criado com sucesso!');
    } else {
      throw Exception('Falha ao registrar funcionario: ${response.body}');
    }
  }

  // Deletar funcionario
  Future<void> deleteEmployee({
    required int id,
  }) async {
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('$baseUrl/funcionarios/$id');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
    );

    if (response.statusCode == 201) {
      print('Funcionario deletado com sucesso!');
    } else {
      throw Exception('Falha ao deletar funcionario: ${response.body}');
    }
  }

  // Listar funcionario
  Future<List<Employee>> getEmployees() async {
    _jwtToken = await getToken();
    _idEnterprise = await getId();
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }
    final url =
        Uri.parse('$baseUrl/funcionarios/listarPelaEmpresa/$_idEnterprise');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
    );
    if (response.statusCode == 201) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final responseData = jsonResponse
          .map((funcionario) => Employee.fromJson(funcionario))
          .toList();
      return responseData;
    } else {
      throw Exception('Falha ao listar Funcionarios: ${response.body}');
    }
  }

  // Detalhe do Funcionario
  Future<Employee> getIdEmployee(int id) async {
    _jwtToken = await getToken();
    _idEnterprise = await getId();
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }
    final url = Uri.parse('$baseUrl/funcionarios/consultar/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
    );
    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final funcionario = Employee.fromJson(jsonResponse);
      print("bianca: $funcionario");
      return funcionario;
    } else {
      throw Exception('Falha ao listar detalhe: ${response.body}');
    }
  }

  Future<void> registerScheduleWithNewClient({
    required int idService,
    required String date, // "2025-10-10"
    required String time, // "14:30:00"
    required String email,
    required String cpf,
    required String name,
    required String celPhone,
  }) async {
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('$baseUrl/agendamentos/registerCliente');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
      body: jsonEncode(
        {
          "idServico": idService,
          "data": date,
          "horario": time,
          "cliente": {
            "email": email,
            "cpf": cpf,
            "nome": name,
            "telefone": celPhone,
          },
        },
      ),
    );

    if (response.statusCode == 201) {
      print('Agendamento criado com sucesso!');
    } else {
      throw Exception('Falha ao criar agendamento: ${response.body}');
    }
  }

  Future<List<Scheduling>> getScheduling() async {
    _jwtToken = await getToken();
    _idEnterprise = await getId();
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }
    final url =
        Uri.parse('$baseUrl/agendamentos/listarPelaEmpresa/$_idEnterprise');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
    );
    if (response.statusCode == 201) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final responseData = jsonResponse
          .map((agendamento) => Scheduling.fromJson(agendamento))
          .toList();
      return responseData;
    } else {
      throw Exception('Falha ao listar agendamentos: ${response.body}');
    }
  }

  Future<List<Customer>> getCustomers() async {
    _jwtToken = await getToken();
    _idEnterprise = await getId();
    if (_jwtToken == null) {
      throw Exception('Usuário não autenticado.');
    }
    final url = Uri.parse('$baseUrl/cliente_interno');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
    );
    if (response.statusCode == 201) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final responseData =
          jsonResponse.map((c) => Customer.fromJson(c)).toList();
      return responseData;
    } else {
      throw Exception('Falha ao listar Clientes: ${response.body}');
    }
  }

  /// Rota: POST /cliente_interno/register
  Future<bool> createInternalCustomer({
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/cliente_interno/register');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'telefone': telefone,
      }),
    );

    if (response.statusCode == 201) {
      print('Cliente interno criado com sucesso!');
      return true;
    } else {
      print(
          'Falha ao criar cliente interno: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao criar cliente interno: ${response.body}');
    }
  }

  /// Rota: GET /cliente_interno/
  /// Updates the existing getCustomers to match the new routes for "cliente_interno"
  Future<List<Customer>> getInternalCustomers() async {
    final headers = await _getHeaders();
    // Note the trailing slash to match `routes.get('/', ...)` in Express
    final url = Uri.parse('$baseUrl/cliente_interno/');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Backend returns 200 for getAllClienteInterno
      final List<dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((data) => Customer.fromJson(data)).toList();
    } else {
      print(
          'Falha ao listar clientes internos: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao listar clientes internos: ${response.body}');
    }
  }

  /// Rota: GET /cliente_interno/:id
  Future<Customer?> getOneInternalCustomer(int id) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/cliente_interno/$id');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final dynamic jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse != null) {
        return Customer.fromJson(jsonResponse);
      }
      return null; // Should not happen if API guarantees a customer or error
    } else if (response.statusCode == 404) {
      // Or whatever your API returns for not found
      print('Cliente interno não encontrado: $id');
      return null;
    } else {
      print(
          'Falha ao buscar cliente interno: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao buscar cliente interno: ${response.body}');
    }
  }

  /// Rota: PUT /cliente_interno/:id
  Future<bool> updateInternalCustomer(
    int id, {
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/cliente_interno/$id');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'telefone': telefone,
      }),
    );

    if (response.statusCode == 200) {
      // Backend returns 200 for update
      print('Cliente interno atualizado com sucesso!');
      return true;
    } else {
      print(
          'Falha ao atualizar cliente interno: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao atualizar cliente interno: ${response.body}');
    }
  }

  /// Rota: DELETE /cliente_interno/:id
  Future<bool> deleteInternalCustomer(int id) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/cliente_interno/$id');
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      // Backend returns 200 for delete
      print('Cliente interno deletado com sucesso!');
      return true;
    } else {
      print(
          'Falha ao deletar cliente interno: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao deletar cliente interno: ${response.body}');
    }
  }
}
