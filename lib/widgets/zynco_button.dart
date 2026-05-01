import 'package:flutter/material.dart';
import '../theme.dart';

class ZyncoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final Widget? icon;
  final double? width;

  const ZyncoButton({super.key, required this.label, this.onPressed, this.loading = false, this.outlined = false, this.icon, this.width});

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : icon != null
            ? Row(mainAxisSize: MainAxisSize.min, children: [icon!, const SizedBox(width: 8), Text(label)])
            : Text(label);

    final btn = outlined
        ? OutlinedButton(onPressed: loading ? null : onPressed, child: child)
        : ElevatedButton(onPressed: loading ? null : onPressed, child: child);

    return width != null ? SizedBox(width: width, child: btn) : btn;
  }
}

class ZyncoGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const ZyncoGradientButton({super.key, required this.label, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: ZyncoColors.gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: ZyncoColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
