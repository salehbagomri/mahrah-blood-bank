import 'package:flutter/material.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';

/// قائمة منسدلة مخصصة
class CustomDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
                      ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
            border: Border.all(
              color: AppTheme.dividerColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppTheme.textSecondary,
                              ),
              prefixIcon: Icon(
                icon,
                color: AppTheme.primaryRed,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                                      ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppTheme.primaryRed,
            ),
            dropdownColor: Colors.white,
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}
