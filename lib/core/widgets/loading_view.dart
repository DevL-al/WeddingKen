import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Memuat data...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.mocha),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
