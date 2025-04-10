import 'dart:convert';

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
      throw Exception('Falha ao listar TODOs: ${response.body}');
    }
  }

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
      throw Exception('Falha ao listar TODOs: ${response.body}');
    }
  }
}
