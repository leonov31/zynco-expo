
import 'package:flutter/material.dart';
import '../../main.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Saved'), backgroundColor: ZyncoColors.background),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: ZyncoColors.textSecondary),
            SizedBox(height: 16),
            Text('No saved providers yet', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 16)),
            SizedBox(height: 8),
            Text('Heart providers you like to save them here', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
