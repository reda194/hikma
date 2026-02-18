import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// PositionUtils provides helper functions for window positioningarian position calculations
class PositionUtils {
  PositionUtils._();

  /// Ensure popup position is visible on screen
  static Future<Offset> ensureVisibleOnScreen(Offset position) async {
    final screen = await _getScreenSize();

    final maxX = screen.width - 480; // popup width
    final maxY = screen.height - 300; // estimated popup height

    double x = position.dx;
    double y = position.dy;

    // Keep popup on screen
    if (x < 0) x = 10;
    if (y < 0) y = 10;
    if (x > maxX) x = maxX - 10;
    if (y > maxY) y = maxY - 10;

    return Offset(x, y);
  }

  /// Get default center position
  static Future<Offset> getCenterPosition() async {
    final screen = await _getScreenSize();
    return Offset(
      (screen.width - 480) / 2,
      (screen.height - 300) / 2,
    );
  }

  /// Get screen size
  static Future<Size> _getScreenSize() async {
    final rect = await windowManager.getBounds();
    return Size(rect.width, rect.height);
  }

  /// Check if position is off-screen
  static Future<bool> isOffScreen(Offset position) async {
    final screen = await _getScreenSize();
    return position.dx < 0 ||
        position.dx > screen.width - 480 ||
        position.dy < 0 ||
        position.dy > screen.height - 300;
  }
}
