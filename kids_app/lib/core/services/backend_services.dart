import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendServices {
  final String baseUrl;

  BackendServices({required this.baseUrl});

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

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
        return true;
      } else {
        print('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
}
