import 'package:flutter/material.dart';

class LanguageBottomSheet extends StatelessWidget {
  final Function(String) onLanguageSelected;

  const LanguageBottomSheet({super.key, required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Language options
            _buildLanguageOption(
              flag: '🇫🇷',
              language: 'French',
              isSelected: true,
              onTap: () => onLanguageSelected('French'),
            ),

            _buildDivider(),

            _buildLanguageOption(
              flag: '🇸🇦',
              language: 'Arabic',
              isSelected: false,
              onTap: () => onLanguageSelected('Arabic'),
            ),

            _buildDivider(),

            _buildLanguageOption(
              flag: '🇬🇧',
              language: 'English',
              isSelected: false,
              onTap: () => onLanguageSelected('English'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String language,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: isSelected ? Colors.grey.shade100 : Colors.transparent,
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE));
  }
}

// Example of how to show this bottom sheet
