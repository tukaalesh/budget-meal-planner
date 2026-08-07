// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:sho_htghadona/main.dart';


// const _kBaseUrl = 'http://10.0.2.2:8000/api';

class ApiResult<T> {
  final T? data;
  final String? error;
  bool get isSuccess => error == null;

  const ApiResult.success(this.data) : error = null;
  const ApiResult.failure(this.error) : data = null;
}

class SearchApiService {
  static final _client = http.Client();

  /// GET /api/ingredients/search?query=
  static Future<ApiResult<List<String>>> searchIngredients(String query) async {
    if (query.trim().isEmpty) return ApiResult.success([]);
    try {
      final uri = Uri.parse('$kBaseUrl/ingredients/search')
          .replace(queryParameters: {'query': query.trim()});

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(Duration(seconds: 8));

      return _parseListResponse(response);
    } on TimeoutException {
      return ApiResult.failure('انتهى وقت الاتصال، تحقق من الشبكة');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }

  /// GET /api/meals/search?query=[هون في قائمة مكونات ]
  static Future<ApiResult<List<String>>> searchMeals(String query) async {
    if (query.trim().isEmpty) return ApiResult.success([]);
    try {
      final uri = Uri.parse('$kBaseUrl/meals/search')
          .replace(queryParameters: {'query': query.trim()});

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(Duration(seconds: 8));

      return _parseListResponse(response);
    } on TimeoutException {
      return ApiResult.failure('انتهى وقت الاتصال، تحقق من الشبكة');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

 
  static ApiResult<List<String>> _parseListResponse(http.Response response) {
    if (response.statusCode != 200) {
      return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
    }

    try {
      final decoded = json.decode(utf8.decode(response.bodyBytes));

      List<dynamic> raw;

      if (decoded is List) {
        raw = decoded;
      } else if (decoded is Map) {
        raw = (decoded['data'] ?? decoded['results'] ?? decoded['items'] ?? [])
            as List;
      } else {
        return ApiResult.failure('صيغة الاستجابة غير متوقعة');
      }

      final items = raw.map((e) {
        if (e is String) return e;
        if (e is Map) {
          return (e['name'] ?? e['title'] ?? e['label'] ?? e.values.first)
              .toString();
        }
        return e.toString();
      }).toList();

      return ApiResult.success(items);
    } catch (e) {
      return ApiResult.failure('خطأ في قراءة البيانات');
    }
  }
}
