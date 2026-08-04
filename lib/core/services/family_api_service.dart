// // ignore_for_file: prefer_const_constructors

// import 'dart:convert';
// import 'dart:async';
// import 'package:http/http.dart' as http;

// const _kBaseUrl = 'http://127.0.0.1:8000/api';

// // ── Result wrapper
// class ApiResult<T> {
//   final T? data;
//   final String? error;
//   bool get isSuccess => error == null;

//   const ApiResult.success(this.data) : error = null;
//   const ApiResult.failure(this.error) : data = null;
// }

// class FamilyApiService {
//   static final _client = http.Client();

//   /// Body:
//   /// {
//   ///   "family_members": 4,
//   ///   "always_available_ingredients": ["رز", "دجاج"],
//   ///   "allergic_ingredients": [],
//   ///   "disliked_ingredients": ["ثوم"],
//   ///   "favorite_meals": ["شاكرية"],
//   ///   "disliked_meals": []
//   /// }
//   static Future<ApiResult<bool>> saveFamilyInfo({
//     required String token,
//     required int memberCount,
//     required List<String> favoriteMeals,
//     required List<String> dislikedMeals,
//     required List<String> dislikedIngredients,
//     required List<String> allergicIngredients,
//     required List<String> alwaysAvailableIngredients,
//   }) async {
//     try {
//       final uri = Uri.parse('$_kBaseUrl/family/setup');

//       final body = json.encode({
//         'family_members': memberCount,
//         'always_available_ingredients': alwaysAvailableIngredients,
//         'allergic_ingredients': allergicIngredients,
//         'disliked_ingredients': dislikedIngredients,
//         'favorite_meals': favoriteMeals,
//         'disliked_meals': dislikedMeals,
//       });

//       final response = await _client
//           .post(
//             uri,
//             headers: {
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//             body: body,
//           )
//           .timeout(Duration(seconds: 10));

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return ApiResult.success(true);
//       } else {
       
//         try {
//           final decoded = json.decode(utf8.decode(response.bodyBytes));
//           final msg = decoded['message'] ??
//               decoded['error'] ??
//               'خطأ ${response.statusCode}';
//           return ApiResult.failure(msg.toString());
//         } catch (_) {
//           return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
//         }
//       }
//     } on TimeoutException {
//       return ApiResult.failure('تحقق من الشبكة');
//     } catch (e) {
//       return ApiResult.failure('خطأ في الاتصال بالخادم');
//     }
//   }
// }
// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../features/family/models/family_model.dart'; // عدّل المسار حسب مكان الموديل عندك

const _kBaseUrl = 'http://127.0.0.1:8000/api';

// ── Result wrapper
class ApiResult<T> {
  final T? data;
  final String? error;
  bool get isSuccess => error == null;

  const ApiResult.success(this.data) : error = null;
  const ApiResult.failure(this.error) : data = null;
}

class FamilyApiService {
  static final _client = http.Client();

  /// POST /family/setup
  /// Body:
  /// {
  ///   "family_members": 4,
  ///   "always_available_ingredients": ["رز", "دجاج"],
  ///   "allergic_ingredients": [],
  ///   "disliked_ingredients": ["ثوم"],
  ///   "favorite_meals": ["شاكرية"],
  ///   "disliked_meals": []
  /// }
  static Future<ApiResult<bool>> saveFamilyInfo({
    required String token,
    required int memberCount,
    required List<String> favoriteMeals,
    required List<String> dislikedMeals,
    required List<String> dislikedIngredients,
    required List<String> allergicIngredients,
    required List<String> alwaysAvailableIngredients,
  }) async {
    try {
      final uri = Uri.parse('$_kBaseUrl/family/setup');

      final body = json.encode({
        'family_members': memberCount,
        'always_available_ingredients': alwaysAvailableIngredients,
        'allergic_ingredients': allergicIngredients,
        'disliked_ingredients': dislikedIngredients,
        'favorite_meals': favoriteMeals,
        'disliked_meals': dislikedMeals,
      });

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(true);
      } else {
        try {
          final decoded = json.decode(utf8.decode(response.bodyBytes));
          final msg = decoded['message'] ??
              decoded['error'] ??
              'خطأ ${response.statusCode}';
          return ApiResult.failure(msg.toString());
        } catch (_) {
          return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
        }
      }
    } on TimeoutException {
      return ApiResult.failure('تحقق من الشبكة');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }

  /// GET /family/profile
  /// Response:
  /// {
  ///   "family_size": 4,
  ///   "always_available_ingredients": [],
  ///   "allergic_ingredients": [],
  ///   "disliked_ingredients": [],
  ///   "favorite_meals": [],
  ///   "disliked_meals": []
  /// }
  static Future<ApiResult<FamilyModel>> fetchFamilyProfile({
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$_kBaseUrl/family/profile');

      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final map = (decoded is Map && decoded['data'] is Map)
            ? decoded['data'] as Map<String, dynamic>
            : decoded as Map<String, dynamic>;
        return ApiResult.success(FamilyModel.fromJson(map));
      } else {
        try {
          final decoded = json.decode(utf8.decode(response.bodyBytes));
          final msg = decoded['message'] ??
              decoded['error'] ??
              'خطأ ${response.statusCode}';
          return ApiResult.failure(msg.toString());
        } catch (_) {
          return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
        }
      }
    } on TimeoutException {
      return ApiResult.failure('تحقق من الشبكة');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }
  /// Response: { "message": "تم تعديل معلومات العائلة بنجاح" }
  static Future<ApiResult<bool>> updateFamilyInfo({
    required String token,
    required int memberCount,
    required List<String> favoriteMeals,
    required List<String> dislikedMeals,
    required List<String> dislikedIngredients,
    required List<String> allergicIngredients,
    required List<String> alwaysAvailableIngredients,
  }) async {
    try {
      final uri = Uri.parse('$_kBaseUrl/family/profile');

      final body = json.encode({
        'family_members': memberCount,
        'always_available_ingredients': alwaysAvailableIngredients,
        'allergic_ingredients': allergicIngredients,
        'disliked_ingredients': dislikedIngredients,
        'favorite_meals': favoriteMeals,
        'disliked_meals': dislikedMeals,
      });

      final response = await _client
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(true);
      } else {
        try {
          final decoded = json.decode(utf8.decode(response.bodyBytes));
          final msg = decoded['message'] ??
              decoded['error'] ??
              'خطأ ${response.statusCode}';
          return ApiResult.failure(msg.toString());
        } catch (_) {
          return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
        }
      }
    } on TimeoutException {
      return ApiResult.failure('تحقق من الشبكة');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }
}