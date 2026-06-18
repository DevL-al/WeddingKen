import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_logo.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(compact ? 20 : 24, compact ? 20 : 24, compact ? 20 : 24, compact ? 22 : 28),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.mocha.withOpacity(0.20), blurRadius: 28, offset: const Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(right: -40, top: -40, child: _DecorCircle(size: 130, opacity: 0.10)),
          Positioned(right: 60, bottom: -60, child: _DecorCircle(size: 90,  opacity: 0.07)),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: AppLogo(light: true)),
                  if (trailing != null) trailing!,
                ],
              ),
              SizedBox(height: compact ? 18 : 22),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 22 : 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.champagne,
                    fontSize: 13.5,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}