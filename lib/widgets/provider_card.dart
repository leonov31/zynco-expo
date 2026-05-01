import 'package:flutter/material.dart';
import '../theme.dart';
import 'zynco_avatar.dart';

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const ProviderCard({super.key, required this.provider, this.onTap, this.onFavorite, this.isFavorite = false});

  @override
  Widget build(BuildContext context) {
    final categories = (provider['categories'] as List?)?.cast<String>() ?? [];
    final rating = (provider['rating'] ?? 0.0).toDouble();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ZyncoAvatar(url: provider['avatar_url'], name: provider['display_name'] ?? '?', size: 56, showRing: provider['is_online'] == true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(provider['display_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                        if (onFavorite != null)
                          GestureDetector(
                            onTap: onFavorite,
                            child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : ZyncoColors.textSecondary, size: 20),
                          ),
                      ],
                    ),
                    if (provider['city'] != null) ...[
                      const SizedBox(height: 2),
                      Text(provider['city'], style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 12)),
                    ],
                    const SizedBox(height: 6),
                    if (categories.isNotEmpty)
                      Wrap(spacing: 4, children: categories.take(3).map((c) => Chip(label: Text(c, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList()),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: ZyncoColors.textSecondary)),
                        if (provider['is_online'] == true) ...[
                          const SizedBox(width: 8),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: ZyncoColors.success, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          const Text('Online', style: TextStyle(color: ZyncoColors.success, fontSize: 11)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
