import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../icons/app_huge_icons.dart';

class AppIcon extends StatelessWidget {
  final AppIconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// Scale factor to compensate for HugeIcons filling the 24×24 SVG canvas
  /// almost edge-to-edge, unlike Material Icons which have ~2px optical margin.
  double _hugeIconRenderSize(double baseSize) {
    if (baseSize <= 16) return baseSize * 0.85;
    if (baseSize <= 24) return baseSize * 0.78;
    if (baseSize <= 36) return baseSize * 0.75;
    return baseSize * 0.72;
  }

  @override
  Widget build(BuildContext context) {
    if (icon is AppHugeIconData) {
      final double baseSize = size ?? 24;
      final double renderSize = _hugeIconRenderSize(baseSize);
      // Keep container at baseSize for correct alignment/layout,
      // only scale the inner SVG icon to match Material Icons visual density.
      return SizedBox.square(
        dimension: baseSize,
        child: Center(
          child: HugeIcon(
            icon: icon as AppHugeIconData,
            size: renderSize,
            color: color,
          ),
        ),
      );
    }

    if (icon is IconData) {
      return Icon(
        icon as IconData,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }

    if (icon is String) {
      final double baseSize = size ?? 24;
      final double renderSize = _hugeIconRenderSize(baseSize);
      if ((icon as String).endsWith('.svg')) {
        return SizedBox.square(
          dimension: baseSize,
          child: Center(
            child: SvgPicture.asset(
              icon as String,
              width: renderSize,
              height: renderSize,
              colorFilter: color != null
                  ? ColorFilter.mode(color!, BlendMode.srcIn)
                  : null,
              semanticsLabel: semanticLabel,
            ),
          ),
        );
      }
    }

    return SizedBox.square(dimension: size ?? 24);
  }
}
