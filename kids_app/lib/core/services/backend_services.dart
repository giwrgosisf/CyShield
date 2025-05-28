import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl;
  String get _uid => _auth.currentUser!.uid;

  BackendServices({required this.baseUrl});

  Future<Map<String, dynamic>> sendTelegramCredentials({
    required String phoneNumber,
    required String apiHash,
    required String apiId,
  }) async {
    final requestBody = {
      "phone_number": phoneNumber,
      "api_id": int.parse(apiId.trim()),
      "api_hash": apiHash.trim(),
    };

    // Debug: Print request details
    if (kDebugMode) {
      print('=== SEND CODE REQUEST ===');
      print('URL: http://192.168.1.88:7000/send-code');
      print('Request Body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.88:7000/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Debug: Print response details
      if (kDebugMode) {
        print('=== SEND CODE RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Raw Response Body: ${response.body}');
        print('Response Body Type: ${response.body.runtimeType}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('Parsed Response Data: $data');
          print('Data Type: ${data.runtimeType}');
          print('Status: ${data['status']}');
        }

        final status = data['status'];

        if (status == 'code_sent') {
          final phoneHash = data['phone_code_hash'];
          if (kDebugMode) {
            print('Phone Code Hash: $phoneHash');
          }
          return {
            'status': 'code_sent',
            'phone_code_hash': phoneHash,
            'api_id': apiId,
            'phone_number': phoneNumber,
            'api_hash': apiHash,
          };
        } else if (status == 'already_authorized') {
          if (kDebugMode) {
            print('User already authorized');
          }
          return {'status': 'already_authorized'};
        } else {
          if (kDebugMode) {
            print('Unknown status received: $status');
          }
          return {'status': 'error', 'message': 'Unknown status: $status'};
        }
      } else {
        if (kDebugMode) {
          print('HTTP Error Response: ${response.statusCode} - ${response.body}');
        }
        return {
          'status': 'error',
          'message': 'HTTP ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('=== SEND CODE ERROR ===');
        print('Exception: $e');
        print('Exception Type: ${e.runtimeType}');
      }
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> confirmTelegramCredentials({
    required String phoneNumber,
    required String apiHash,
    required String apiId,
    String? code,
    String? phoneCodeHash,
    String? password,
  }) async {
    final requestBody = {
      "phone_number": phoneNumber,
      "api_id": int.parse(apiId.trim()),
      "api_hash": apiHash.trim(),
      "code": code ?? "",
      "phone_code_hash": phoneCodeHash ?? "",
      "password": password ?? "",
    };

    // Debug: Print request details
    if (kDebugMode) {
      print('=== CONFIRM CODE REQUEST ===');
      print('URL: http://192.168.1.88:7000/login');
      print('Request Body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.88:7000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );


      if (kDebugMode) {
        print('=== CONFIRM CODE RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Raw Response Body: ${response.body}');
        print('Response Body Type: ${response.body.runtimeType}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (kDebugMode) {
          print('Parsed Response Data: $responseData');
          print('Data Type: ${responseData.runtimeType}');
        }

        // Handle both Map and String responses
        if (responseData is Map<String, dynamic>) {
          final String status = responseData['status'] ?? 'unknown';
          if (kDebugMode) {
            print('Map Response - Status: $status');
            print('Map Response - Message: ${responseData['message']}');
          }
          return {
            'status': status,
            'message': responseData['message']?.toString() ?? '',
          };
        } else if (responseData is String) {
          if (kDebugMode) {
            print('String Response: $responseData');
          }
          return {
            'status': responseData,
            'message': '',
          };
        } else {
          if (kDebugMode) {
            print('Unexpected response format: ${responseData.runtimeType}');
          }
          return {
            'status': 'error',
            'message': 'Unexpected response format',
          };
        }
      } else {
        if (kDebugMode) {
          print('HTTP Error Response: ${response.statusCode} - ${response.body}');
        }
        return {
          'status': 'error',
          'message': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('=== CONFIRM CODE ERROR ===');
        print('Exception: $e');
        print('Exception Type: ${e.runtimeType}');
      }
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<bool> notifyParent({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final url = Uri.parse('$baseUrl:8000/message/FcmRequest');

    final payload = {
      'userId': userId,
      'title': title,
      'body': body,
      'data': data ?? {},
    };

    if (kDebugMode) {
      print('=== NOTIFY PARENT REQUEST ===');
      print('URL: $url');
      print('Payload: ${jsonEncode(payload)}');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('=== NOTIFY PARENT RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Notification sent successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to send notification: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('=== NOTIFY PARENT ERROR ===');
        print('Error sending notification: $e');
      }
      return false;
    }
  }

  Future<bool> getTelegramState() async {
    final doc = await _db.collection('kids').doc(_uid).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    return data['telegram_state'] as bool? ?? false;
  }

  Future<bool> getSignalState() async {
    final doc = await _db.collection('kids').doc(_uid).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    return data['signal_state'] as bool? ?? false;
  }

  Future<void> setTelegramState(bool newState) async {
    await _db.collection('kids').doc(_uid).update({'telegram_state': newState});
  }

  Future<void> setSignalState(bool newState) async {
    await _db.collection('kids').doc(_uid).update({'signal_state': newState});
  }


}