import 'package:flutter/widgets.dart';

class Responsive {
  static late double _w;
  static late double _h;
  static late double _textScale;

  /// Call once per route (e.g., via MaterialApp.builder)
  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    _w = mq.size.width;
    _h = mq.size.height;
    _textScale = mq.textScaleFactor;
  }

  // Width percent (0-100)
  static double wp(double percent) => _w * (percent / 100);

  // Height percent (0-100)
  static double hp(double percent) => _h * (percent / 100);

  // Scaled font based on base width (375)
  static double sp(double size) => size * (_w / 375) * _textScale;
}
