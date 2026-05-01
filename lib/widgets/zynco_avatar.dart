import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';

class ZyncoAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  final bool showRing;

  const ZyncoAvatar({super.key, this.url, required this.name, this.size = 48, this.showRing = false});

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: ZyncoColors.surface2,
      backgroundImage: url != null ? CachedNetworkImageProvider(url!) : null,
      child: url == null
          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.bold))
          : null,
    );

    if (!showRing) return avatar;
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: ZyncoColors.gradient,
      ),
      child: Padding(padding: const EdgeInsets.all(2), child: avatar),
    );
  }
}
