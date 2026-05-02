import 'package:flutter/material.dart';

class TopicCard extends StatelessWidget {
  final String icon;
  final String label;
  final String description;
  final Color accentColor;
  final bool comingSoon;
  final String comingSoonLabel;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.accentColor,
    required this.onTap,
    this.comingSoon = false,
    this.comingSoonLabel = 'Soon',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: comingSoon ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: accentColor, width: 5)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: comingSoon
                              ? colorScheme.onSurface.withOpacity(0.4)
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (comingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            comingSoonLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            if (!comingSoon)
              Icon(Icons.arrow_forward_ios, size: 14, color: accentColor),
          ],
        ),
      ),
    );
  }
}
