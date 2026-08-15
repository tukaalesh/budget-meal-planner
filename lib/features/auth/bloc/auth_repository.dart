// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:sho_htghadona/main.dart';

import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  // final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$kBaseUrl/register');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    print('REGISTER STATUS: ${response.statusCode}');
    print('REGISTER BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    }

    throw Exception(_extractError(response.body));
  }

  String _extractError(String body) {
    try {
      final data = jsonDecode(body);

      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;

        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }

      return 'حدث خطأ غير متوقع';
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$kBaseUrl/login');
    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    }

    throw Exception(_extractError(response.body));
  }

  Future<void> logout(String token) async {
    final uri = Uri.parse('$kBaseUrl/logout');
    await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
