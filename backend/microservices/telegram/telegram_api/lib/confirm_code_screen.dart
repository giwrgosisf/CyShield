import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'live_message_screen.dart';

class ConfirmCodeScreen extends StatefulWidget {
  final String phone;
  final int apiId;
  final String apiHash;
  final String phoneCodeHash;

  const ConfirmCodeScreen({
    super.key,
    required this.phone,
    required this.apiId,
    required this.apiHash,
    required this.phoneCodeHash,
  });

  @override
  State<ConfirmCodeScreen> createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends State<ConfirmCodeScreen> {
  final TextEditingController _codeController = TextEditingController();

  Future<void> confirmCode() async {
    final Map<String, dynamic> loginData = {
      "phone_number": widget.phone,
      "api_id": widget.apiId,
      "api_hash": widget.apiHash,
      "code": _codeController.text.trim(),
      "phone_code_hash": widget.phoneCodeHash,
      "password": null,
      "api_id runtimeType":widget.apiId.runtimeType
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loginData.toString())),
    );

    final response = await http.post(
      Uri.parse('http://192.168.1.79:8000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "phone_number": widget.phone,
        "api_id": widget.apiId,
        "api_hash": widget.apiHash,
        "code": _codeController.text.trim(),
        "phone_code_hash": widget.phoneCodeHash,
        "password": "",
      }),
    );

    if (kDebugMode) {
      print("Login response code: ${response.statusCode}");
      print("Login response body: ${response.body}");
    }

    if (response.statusCode == 200) {
      // ✅ Success branch
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final String status = decoded['status'];

        if (status == 'success' || status == 'already_authorized') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LiveMessageScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown status received')),
          );
        }
      } else if (decoded is String) {
        // If backend returns just a string (rare)
        if (decoded == 'already_authorized') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LiveMessageScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unexpected string response: $decoded')),
          );
        }
      }
    } else {
      // ❌ Only enter here if server gave real error (status != 200)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed with status ${response.statusCode}')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Code')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Code')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: confirmCode,
              child: const Text('Confirm Code'),
            ),
          ],
        ),
      ),
    );
  }
}
