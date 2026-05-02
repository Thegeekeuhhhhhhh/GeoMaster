import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';

class LanguageSheet extends StatelessWidget {
  final AppLanguage current;
  final ValueChanged<AppLanguage> onChanged;

  const LanguageSheet({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.values.map((lang) {
          final selected = lang == current;
          return ListTile(
            leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
            title: Text(
              lang.label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? const Color(0xFF1A237E)
                    : const Color(0xFF333333),
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check, color: Color(0xFF1A237E))
                : null,
            onTap: () => onChanged(lang),
          );
        }).toList(),
      ),
    );
  }
}
