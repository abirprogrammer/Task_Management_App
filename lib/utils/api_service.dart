import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/task_model.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  /// Common headers for JSON requests.
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Sends a request and safely parses the JSON response.
  static Future<Map<String, dynamic>> _sendRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse(url);

      if (!uri.hasScheme ||
          (uri.scheme != 'https' && uri.scheme != 'http') ||
          uri.host.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid API URL. Check ApiConstants.',
        };
      }

      late http.Response response;

      if (method == 'GET') {
        response = await http.get(
          uri,
          headers: const {'Accept': 'application/json'},
        ).timeout(_timeout);
      } else {
        response = await http.post(
          uri,
          headers: _headers,
          body: jsonEncode(body ?? <String, dynamic>{}),
        ).timeout(_timeout);
      }

      debugPrint('API URL: $uri');
      debugPrint('HTTP Status: ${response.statusCode}');
      debugPrint('API Response: ${response.body}');

      if (response.body.trim().isEmpty) {
        return {
          'success': false,
          'message':
          'The server returned an empty response '
              '(HTTP ${response.statusCode}).',
        };
      }

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } on FormatException catch (e) {
        debugPrint('JSON parsing error: $e');

        return {
          'success': false,
          'message':
          'The server returned invalid JSON. '
              'Check the PHP API and server error logs.',
        };
      }

      if (decoded is! Map) {
        return {
          'success': false,
          'message': 'Unexpected API response format.',
        };
      }

      final data = Map<String, dynamic>.from(decoded);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return {
          ...data,
          'success': false,
          'message': data['message']?.toString() ??
              'Server error: HTTP ${response.statusCode}',
        };
      }

      return data;
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again.',
      };
    } on FormatException catch (e) {
      debugPrint('Invalid URL or data format: $e');

      return {
        'success': false,
        'message': 'Invalid URL or data format.',
      };
    } catch (e, stackTrace) {
      debugPrint('API request error: $e');
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Login
  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    return _sendRequest(
      method: 'POST',
      url: ApiConstants.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );
  }

  /// Register
  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String address,
      String password,
      ) async {
    return _sendRequest(
      method: 'POST',
      url: ApiConstants.register,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'address': address.trim(),
        'password': password,
      },
    );
  }

  /// Send OTP
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    return _sendRequest(
      method: 'POST',
      url: ApiConstants.sendOtp,
      body: {
        'email': email.trim(),
      },
    );
  }

  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    return _sendRequest(
      method: 'POST',
      url: ApiConstants.verifyOtp,
      body: {
        'email': email.trim(),
        'otp': otp.trim(),
      },
    );
  }

  /// Upload Profile Image
  static Future<Map<String, dynamic>> uploadProfileImage(int userId, String imageBase64) async {
    return _sendRequest(
      method: 'POST',
      url: ApiConstants.uploadProfile,
      body: {
        'user_id': userId,
        'image_base64': imageBase64,
      },
    );
  }

  /// Update Profile Details
  static Future<Map<String, dynamic>> updateProfile(int userId, String name, String email, String address) async {
    return _sendRequest(
      method: 'POST',
      url: ApiConstants.updateProfile,
      body: {
        'user_id': userId,
        'name': name.trim(),
        'email': email.trim(),
        'address': address.trim(),
      },
    );
  }

  /// Change Password
  static Future<Map<String, dynamic>> changePassword(int userId, String currentPassword, String newPassword) async {
    return _sendRequest(
      method: 'POST',
      url: ApiConstants.changePassword,
      body: {
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  /// Get tasks for a user
  static Future<List<TaskModel>> getTasks(int userId) async {
    try {
      final uri = Uri.parse(ApiConstants.getTasks).replace(
        queryParameters: {
          ...Uri.parse(ApiConstants.getTasks).queryParameters,
          'user_id': userId.toString(),
        },
      );

      final data = await _sendRequest(
        method: 'GET',
        url: uri.toString(),
      );

      if (data['success'] != true || data['tasks'] is! List) {
        debugPrint('getTasks failed: ${data['message']}');
        return [];
      }

      return (data['tasks'] as List)
          .whereType<Map>()
          .map(
            (json) => TaskModel.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();
    } catch (e, stackTrace) {
      debugPrint('getTasks error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  /// Add task
  static Future<bool> addTask(
      int userId,
      String title,
      String description,
      String category,
      String dueDate,
      String priority,
      ) async {
    final data = await _sendRequest(
      method: 'POST',
      url: ApiConstants.addTask,
      body: {
        'user_id': userId,
        'title': title,
        'description': taskTitleOrDesc(title, description),
        'category': category,
        'due_date': dueDate,
        'priority': priority,
      },
    );

    return data['success'] == true;
  }

  static String taskTitleOrDesc(String title, String desc) => desc;

  /// Update task
  static Future<bool> updateTask(TaskModel task) async {
    final data = await _sendRequest(
      method: 'POST',
      url: ApiConstants.updateTask,
      body: {
        'id': task.id,
        'user_id': task.userId,
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'due_date': task.dueDate,
        'priority': task.priority,
        'is_completed': task.isCompleted ? 1 : 0,
      },
    );

    return data['success'] == true;
  }

  /// Delete task
  static Future<bool> deleteTask(
      int taskId,
      int userId,
      ) async {
    final data = await _sendRequest(
      method: 'POST',
      url: ApiConstants.deleteTask,
      body: {
        'id': taskId,
        'user_id': userId,
      },
    );

    return data['success'] == true;
  }
}
