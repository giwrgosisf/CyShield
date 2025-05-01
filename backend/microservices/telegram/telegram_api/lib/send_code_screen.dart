import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'confirm_code_screen.dart';
import 'live_message_screen.dart';

class SendCodeScreen extends StatefulWidget {
  const SendCodeScreen({super.key});

  @override
  State<SendCodeScreen> createState() => _SendCodeScreenState();
}

class _SendCodeScreenState extends State<SendCodeScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _apiIdController = TextEditingController();
  final TextEditingController _apiHashController = TextEditingController();

  Future<void> sendCode() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.79:8000/send-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "phone_number": _phoneController.text.trim(),
        "api_id": int.parse(_apiIdController.text.trim()),
        "api_hash": _apiHashController.text.trim(),
      }),
    );

    final data = jsonDecode(response.body);
    if (kDebugMode) {
      print("Server responded: ${response.body}");
    }

    final status = data['status'];

    if (response.statusCode == 200) {
      if (status == 'already_authorized') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LiveMessageScreen()),
        );
      } else if (status == 'code_sent') {
        final String phoneCodeHash = data['phone_code_hash'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmCodeScreen(
              phone: _phoneController.text.trim(),
              apiId: int.parse(_apiIdController.text.trim()),
              apiHash: _apiHashController.text.trim(),
              phoneCodeHash: phoneCodeHash,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected status: $status')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.body}')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Phone Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _apiIdController, decoration: const InputDecoration(labelText: 'API ID')),
            TextField(controller: _apiHashController, decoration: const InputDecoration(labelText: 'API Hash')),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendCode,
              child: const Text('Send Code'),
            ),
          ],
        ),
      ),
    );
  }
}
