import 'package:flutter/material.dart';

/// A reusable card for displaying key-value information pairs.
class InfoCard extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> items;
  final Color? borderColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.items,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ...items.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
