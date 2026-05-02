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
    return GestureDetector(
      onTap: comingSoon ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: accentColor, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
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
                              ? const Color(0xFF999999)
                              : const Color(0xFF222222),
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
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            comingSoonLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF777777),
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
