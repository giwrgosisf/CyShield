import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class PairingForm extends StatefulWidget {
  final void Function(String parentId, String network)? onSubmit;
  final bool isLoading;

  const PairingForm({
    required this.onSubmit,
    this.isLoading = false,
    super.key,
  });

  @override
  State<PairingForm> createState() => _PairingFormState();
}

class _PairingFormState extends State<PairingForm> {
  final _formKey = GlobalKey<FormState>();
  final _parentIdController = TextEditingController();
  String? _selectedNetwork;

  final _networks = [
    'Telegram',
    'Signal',
  ];

  @override
  void dispose() {
    _parentIdController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final parentId = _parentIdController.text.trim();
      final network = _selectedNetwork!;
      widget.onSubmit?.call(parentId, network);
    }
  }

  bool get _isFormDisabled => widget.isLoading || widget.onSubmit == null;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Parent ID field
            TextFormField(
              controller: _parentIdController,
              enabled: !_isFormDisabled,
              decoration: const InputDecoration(
                labelText: 'Συμπλήρωσε το ID γονέα παρακάτω',
                hintText: 'Συμπλήρωσε εδώ',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              v != null && v.trim().isNotEmpty
                  ? null
                  : 'Παρακαλώ εισάγετε το ID',
            ),

            const SizedBox(height: 16),

            // Dropdown
            DropdownButtonFormField<String>(
              value: _selectedNetwork,
              items: _isFormDisabled
                  ? null
                  : _networks
                  .map((net) => DropdownMenuItem(
                value: net,
                child: Text(net),
              ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Επίλεξε μέσο κοινωνικής δικτύωσης',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Μέσο κοινωνικής δικτύωσης'),
              onChanged: _isFormDisabled
                  ? null
                  : (val) => setState(() {
                _selectedNetwork = val;
              }),
              validator: (v) =>
              v == null ? 'Παρακαλώ επιλέξτε ένα δίκτυο' : null,
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormDisabled
                      ? Colors.grey.shade400
                      : AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isFormDisabled ? null : _handleSubmit,
                child: widget.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text('Σύνδεση με γονέα'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}