import 'dart:math';

import 'package:flutter/material.dart';

/// Advanced Avatar widget.
class EnclaveAvatar extends StatelessWidget {
  const EnclaveAvatar({
    Key? key,
    this.name,
    this.size = 80.0,
    this.image,
    this.margin,
    this.style,
    this.statusColor,
    this.statusSize = 12.0,
    this.statusAngle = 135.0,
    this.decoration,
    this.foregroundDecoration,
    this.child,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
    this.fit,
  }) : super(key: key);

  /// Used for creating initials. (Regex split by r'\s+\/')
  final String? name;

  /// Avatar size (width = height).
  final double size;

  /// Avatar image source exclusively with [child].
  final ImageProvider<Object>? image;

  /// Avatar margin.
  final EdgeInsetsGeometry? margin;

  /// Initials text style.
  final TextStyle? style;

  /// Status color.
  final Color? statusColor;

  /// Status size.
  final double statusSize;

  /// Status angle.
  final double statusAngle;

  /// Avatar decoration.
  final BoxDecoration? decoration;

  /// Avatar foreground decoration.
  final BoxDecoration? foregroundDecoration;

  /// Child widget exclusively with [image].
  final Widget? child;

  /// Top-left hosted widget.
  final Widget? topLeft;

  /// Top-right hosted widget.
  final Widget? topRight;

  /// Bottom-left hosted widget.
  final Widget? bottomLeft;

  /// Bottom-right hosted widget.
  final Widget? bottomRight;

  /// fit image.
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UnconstrainedBox(
      child: Container(
        width: size,
        height: size,
        margin: margin,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: decoration ??
                  BoxDecoration(
                    color: theme.backgroundColor,
                    shape: BoxShape.circle,
                  ),
              foregroundDecoration: foregroundDecoration,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onBackground,
                ).merge(style),
                child: child != null
                    ? child!
                    : image != null
                        ? Image(
                            image: image!,
                            fit: fit,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(name.toAbbreviation());
                            },
                          )
                        : Text(name.toAbbreviation()),
              ),
            ),
            if (statusColor != null)
              CornerBox(
                offset: OffsetUtils.angleToOffset(
                  statusAngle,
                  radius: size / 2,
                ),
                child: Container(
                  width: statusSize,
                  height: statusSize,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: theme.dividerTheme.thickness ?? 0.5,
                    ),
                  ),
                ),
              ),
            if (topLeft != null)
              CornerBox(
                offset: OffsetUtils.angleToOffset(
                  315.0,
                  radius: size / 2,
                ),
                child: topLeft,
              ),
            if (topRight != null)
              CornerBox(
                offset: OffsetUtils.angleToOffset(
                  45.0,
                  radius: size / 2,
                ),
                child: topRight,
              ),
            if (bottomLeft != null)
              CornerBox(
                offset: OffsetUtils.angleToOffset(
                  135.0,
                  radius: size / 2,
                ),
                child: bottomLeft,
              ),
            if (bottomRight != null)
              CornerBox(
                offset: OffsetUtils.angleToOffset(
                  225,
                  radius: size / 2,
                ),
                child: bottomRight,
              ),
          ],
        ),
      ),
    );
  }
}

/// Common positioned widget wrapper.
class CornerBox extends StatelessWidget {
  const CornerBox({
    Key? key,
    required this.child,
    this.offset = Offset.zero,
  }) : super(key: key);

  /// Offset position.
  final Offset offset;

  /// Child widget.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: 0,
      height: 0,
      left: offset.dx,
      top: offset.dy,
      child: OverflowBox(
        alignment: Alignment.center,
        minWidth: 0,
        minHeight: 0,
        maxWidth: double.maxFinite,
        maxHeight: double.maxFinite,
        child: child,
      ),
    );
  }
}

/// String utility extension.
extension StringUtils on String? {
  /// Returns a string abbreviation.
  String toAbbreviation() {
    if (this == null) return '';

    final nameParts = this!.trim().toUpperCase().split(RegExp(r'[\s\/]+'));

    if (nameParts.length > 1) {
      return nameParts.first.substring(0, 1) + nameParts.last.substring(0, 1);
    }

    return nameParts.first.substring(0, 1);
  }
}

/// Offset utility extension.
extension OffsetUtils on Offset {
  /// Returns Offset based on [angle] and [radius].
  static Offset angleToOffset(double angle, {double radius = 0.0}) {
    return Offset(
      radius * sin(pi * 2 * angle / 360) + radius,
      radius * -cos(pi * 2 * angle / 360) + radius,
    );
  }
}
