import 'dart:developer';

import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import 'secure_storage_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.example.com';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      String? accessToken = await SecureStorageManager.readData('accessToken');
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      handler.next(options);
    }, onError: (DioException error, handler) async {
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        String? refreshToken =
            await SecureStorageManager.readData('refreshToken');
        if (refreshToken != null) {
          try {
            final response = await refreshTokenAction(refreshToken);

            requestRetry(error.requestOptions, handler, response);
            return;
          } catch (e) {
            await SecureStorageManager.clearAllData();
            handler.next(error);
          }
        }
      }
      handler.next(error);
    }));
  }

  Future<AuthResponse> refreshTokenAction(String refreshToken) async {
    final response = await _dio
        .post('$baseUrl/auth/refresh', data: {'refreshToken': refreshToken});
    if (response.statusCode == 200 || response.statusCode == 201) {
      await SecureStorageManager.writeData(
          'accessToken', response.data['accessToken']);
      if (response.data['refreshToken'] != null) {
        await SecureStorageManager.writeData(
            'refreshToken', response.data['refreshToken']);
      }
      return AuthResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  void requestRetry(RequestOptions requestOptions,
      ErrorInterceptorHandler handler, AuthResponse response) {
    requestOptions.headers['Authorization'] = 'Bearer ${response.accessToken}';
    _dio.fetch(requestOptions).then((res) => handler.resolve(res),
        onError: (e) => handler.next(DioException(
            requestOptions: requestOptions,
            error: 'Failed after token refresh')));
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio
        .post('/auth/login', data: {'email': email, 'password': password});

    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> verifyOtp(String email, String otp) async {
    final response =
        await _dio.post('/auth/verify', data: {'email': email, 'otp': otp});
    log(response.data.toString());
    final res = AuthResponse.fromJson(response.data);
    SecureStorageManager.writeData('accessToken', res.accessToken!);
    SecureStorageManager.writeData('refreshToken', res.refreshToken!);
    log("Access Token ${res.accessToken!}");
    log("Refresh Token ${res.refreshToken!}");
    return res;
  }

  Future<AuthResponse> signUp(
      String name, String email, String password) async {
    final response = await _dio.post('/auth/signup',
        data: {'name': name, 'email': email, 'password': password});
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _dio
        .post('/auth/user/refresh', data: {'refreshToken': refreshToken});
    return AuthResponse.fromJson(response.data);
  }

  Future<Response> getProductByToken() async {
    try {
      final token = await SecureStorageManager.readData('accessToken');
      final response = await _dio.get('/product/1',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response;
    } catch (e) {
      throw Exception('Failed to load product');
    }
  }
}
