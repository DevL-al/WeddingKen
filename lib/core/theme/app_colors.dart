import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const ivory = Color(0xFFFFFBF3);
  static const cream = Color(0xFFFFF3DE);
  static const champagne = Color(0xFFF6DFB8);
  static const gold = Color(0xFFD6A84F);
  static const goldDark = Color(0xFFA5742E);
  static const mocha = Color(0xFF6B4326);
  static const espresso = Color(0xFF26150E);
  static const rose = Color(0xFFB96A72);
  static const roseSoft = Color(0xFFF8E3E1);
  static const sage = Color(0xFF75846D);
  static const ink = Color(0xFF241A16);
  static const muted = Color(0xFF7B6A60);
  static const border = Color(0xFFEEDCC3);
  static const success = Color(0xFF2F8A64);
  static const warning = Color(0xFFC88721);
  static const danger = Color(0xFFC54A42);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [espresso, mocha, goldDark],
  );

  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ivory, cream, roseSoft],
  );
}
