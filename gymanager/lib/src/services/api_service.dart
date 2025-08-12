import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymanager/src/models/member_model.dart';
import 'package:gymanager/src/models/trainer_model.dart';
import 'package:gymanager/src/models/user_model.dart';

class ApiService {
  /// Base URL for the API, adjusting for Android emulator vs. other platforms.
  // static final String _baseUrl = defaultTargetPlatform == TargetPlatform.android
  //     ? 'http://10.0.2.2:5001'
  //     : 'http://localhost:5001';
  // In api_service.dart

  static final String _baseUrl =
      'https://gym-management-app-hpfo.onrender.com/';

  /// A private helper to get authorization headers with the stored JWT token.
  static Future<Map<String, String>> _getAuthHeaders() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- Auth Methods ---

  /// Logs in a user with the given email and password.
  /// Returns a map containing user data and a JWT token.
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to login');
    }
  }

  /// Registers a new user account.
  /// Returns a map containing the new user's data and a JWT token.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to register');
    }
  }

  // --- Profile Methods ---

  /// Fetches the profile of the currently authenticated user.
  static Future<User> getUserProfile() async {
    final url = Uri.parse('$_baseUrl/api/users/profile');
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // --- Member Methods ---

  /// Fetches a list of members, optionally filtered by a search query.
  static Future<List<Member>> getMembers({String? query}) async {
    var uri = Uri.parse('$_baseUrl/api/members');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: {'search': query});
    }
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Member.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load members');
    }
  }

  /// Creates a new member.
  static Future<Member> createMember({
    required String name,
    required String gender,
    required String dob,
    required String membershipPlan,
    String? height,
    String? weight,
    String? trainerId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/members');
    final headers = await _getAuthHeaders();
    final body = json.encode({
      'name': name,
      'gender': gender,
      'dob': dob,
      'membershipPlan': membershipPlan,
      'height': height,
      'weight': weight,
      'trainerId': trainerId,
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 201) {
      return Member.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create member');
    }
  }

  /// Deletes a member by their ID.
  static Future<void> deleteMember(String memberId) async {
    final url = Uri.parse('$_baseUrl/api/members/$memberId');
    final headers = await _getAuthHeaders();
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete member');
    }
  }

  /// Renews a member's membership with a new plan.
  static Future<Member> renewMembership({
    required String memberId,
    required String membershipPlan,
  }) async {
    final url = Uri.parse('$_baseUrl/api/members/$memberId/renew');
    final headers = await _getAuthHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode({'membershipPlan': membershipPlan}),
    );
    if (response.statusCode == 200) {
      return Member.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to renew membership');
    }
  }

  // --- Trainer Methods ---

  /// Fetches a list of all trainers.
  static Future<List<Trainer>> getTrainers() async {
    final url = Uri.parse('$_baseUrl/api/trainers');
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Trainer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trainers');
    }
  }

  /// Creates a new trainer.
  static Future<Trainer> createTrainer({
    required String name,
    required String gender,
  }) async {
    final url = Uri.parse('$_baseUrl/api/trainers');
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({'name': name, 'gender': gender}),
    );
    if (response.statusCode == 201) {
      return Trainer.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create trainer');
    }
  }

  /// Fetches a list of members assigned to a specific trainer.
  static Future<List<Member>> getMembersForTrainer(String trainerId) async {
    final url = Uri.parse('$_baseUrl/api/trainers/$trainerId/members');
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Member.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load members for trainer');
    }
  }

// In api_service.dart

  /// Fetches a list of members with an active membership.
  static Future<List<Member>> getActiveMembers() async {
    final url = Uri.parse('$_baseUrl/api/members/active');
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Member.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active members');
    }
  }
  // In api_service.dart

  /// Sends the user's FCM device token to the backend to be saved.
  static Future<void> saveFcmToken(String fcmToken) async {
    final url = Uri.parse('$_baseUrl/api/users/fcm-token');
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({'token': fcmToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save FCM token.');
    }
  }

  /// Fetches a list of members with an expired membership.
  static Future<List<Member>> getExpiredMembers() async {
    final url = Uri.parse('$_baseUrl/api/members/expired');
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Member.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expired members');
    }
  }
  // --- Analytics Methods ---

  /// Fetches membership statistics for the last 6 months.
  static Future<List<Map<String, dynamic>>> getMembershipStats() async {
    final url = Uri.parse('$_baseUrl/api/analytics/memberships');
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load analytics data');
    }
  }
}
