// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:sho_htghadona/main.dart';

import 'search_api_service.dart' show ApiResult;
import '../../features/recommendations/models/meal_model.dart';
import '../../features/recommendations/models/shopping_list_model.dart';
import '../../features/meal_history/models/plan_history_model.dart';

// const _kBaseUrl = 'http://10.0.2.2:8000/api';

class PlansApiService {
  static final _client = http.Client();

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// POST /api/plans/generate
  /// عملية توليد الخطة قد تأخذ دقيقة أو أكثر أحيانًا، لذلك المهلة
  /// (timeout) موسّعة عمدًا إلى 120 ثانية.
  static Future<ApiResult<GeneratedPlanModel>> generatePlan({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$kBaseUrl/plans/generate');

      final response = await _client
          .post(uri, headers: _headers(token), body: json.encode(body))
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 422) {
        try {
          final decoded = json.decode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;
          final message = decoded['message'] as String?;
          return ApiResult.failure(
              message ?? 'تعذّر توليد خطة بالمواصفات المطلوبة');
        } catch (_) {
          return ApiResult.failure('تعذّر توليد خطة بالمواصفات المطلوبة');
        }
      }

      if (response.statusCode != 200) {
        return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
      }

      final decoded =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResult.success(GeneratedPlanModel.fromJson(decoded));
    } on TimeoutException {
      return ApiResult.failure(
          'استغرق توليد الخطة وقتًا أطول من المتوقع، حاول مرة أخرى');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }

  /// POST /api/plans/accept
  /// يرسل الطلب الأصلي + الخطة الحالية، ويرجع قائمة التسوق.
  static Future<ApiResult<AcceptPlanResponseModel>> acceptPlan({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$kBaseUrl/plans/accept');

      final response = await _client
          .post(uri, headers: _headers(token), body: json.encode(body))
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 422) {
        try {
          final decoded = json.decode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;
          final message = decoded['message'] as String?;
          return ApiResult.failure(message ?? 'تعذّر قبول الخطة');
        } catch (_) {
          return ApiResult.failure('تعذّر قبول الخطة');
        }
      }

      if (response.statusCode != 200) {
        return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
      }

      final decoded =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResult.success(AcceptPlanResponseModel.fromJson(decoded));
    } on TimeoutException {
      return ApiResult.failure('استغرق الاتصال وقتًا طويلاً، حاول مرة أخرى');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }

  /// GET /api/plans
  /// يرجع قائمة الخطط السابقة (ملخص فقط لكل خطة).
  static Future<ApiResult<List<PlanSummary>>> getPlans({
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$kBaseUrl/plans');

      final response = await _client
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes)) as List;
      final plans = decoded
          .map((e) => PlanSummary.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(plans);
    } on TimeoutException {
      return ApiResult.failure('انتهى وقت الاتصال، تحقق من الشبكة');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }

  /// GET /api/plans/{id}
  /// يرجع تفاصيل خطة سابقة كاملة (الوجبات + قائمة التسوق).
  static Future<ApiResult<PlanDetail>> getPlanDetail({
    required int planId,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$kBaseUrl/plans/$planId');

      final response = await _client
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return ApiResult.failure('خطأ ${response.statusCode} من الخادم');
      }

      final decoded =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResult.success(PlanDetail.fromJson(decoded));
    } on TimeoutException {
      return ApiResult.failure('انتهى وقت الاتصال، تحقق من الشبكة');
    } catch (e) {
      return ApiResult.failure('خطأ في الاتصال بالخادم');
    }
  }
}

