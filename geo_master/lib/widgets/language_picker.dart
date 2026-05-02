import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';
import './language_sheet.dart';

class LanguagePicker extends StatelessWidget {
  final AppLanguage current;
  final ValueChanged<AppLanguage> onChanged;

  const LanguagePicker({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => LanguageSheet(
          current: current,
          onChanged: (lang) {
            onChanged(lang);
            Navigator.pop(context);
          },
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(
              current.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
