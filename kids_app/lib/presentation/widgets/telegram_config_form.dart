import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/bloc/telegram/telegram_config_cubit.dart';
import 'package:kids_app/bloc/telegram/telegram_config_state.dart';
import 'package:kids_app/core/app_theme.dart';

class TelegramConfigForm extends StatelessWidget {
  const TelegramConfigForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TelegramConfigCubit, TelegramConfigState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TelegramInputField(
                label: 'API ID',
                hintText: 'Συμπληρώστε εδώ',
                fieldType: TelegramFieldType.apiId,
              ),
              const SizedBox(height: 20),
              const TelegramInputField(
                label: 'API hash',
                hintText: 'Συμπληρώστε εδώ',
                fieldType: TelegramFieldType.apiHash,
              ),
              const SizedBox(height: 20),
              const TelegramInputField(
                label: 'Phone number',
                hintText: 'Συμπληρώστε εδώ',
                fieldType: TelegramFieldType.phoneNumber,
                keyboardType: TextInputType.phone,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.read<TelegramConfigCubit>().submitConfiguration(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Συνέχεια',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum TelegramFieldType { apiId, apiHash, phoneNumber }

class TelegramInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final TelegramFieldType fieldType;
  final TextInputType? keyboardType;

  const TelegramInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.fieldType,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          cursorColor: AppTheme.secondary,
          onChanged: (value) {
            final cubit = context.read<TelegramConfigCubit>();
            switch (fieldType) {
              case TelegramFieldType.apiId:
                cubit.updateApiId(value);
                break;
              case TelegramFieldType.apiHash:
                cubit.updateApiHash(value);
                break;
              case TelegramFieldType.phoneNumber:
                cubit.updatePhoneNumber(value);
                break;
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.secondary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}