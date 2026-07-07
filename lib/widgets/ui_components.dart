import 'dart:ui';

import 'package:barcode_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.backgroundTop,
            colors.backgroundBottom,
            colors.isDark ? const Color(0xFF12172E) : const Color(0xFFE8EEF4),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _GlowOrb(
              color: colors.accent.withValues(alpha: colors.isDark ? 0.18 : 0.12),
              size: 220,
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: _GlowOrb(
              color: colors.accentSecondary.withValues(alpha: colors.isDark ? 0.16 : 0.1),
              size: 180,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 90, spreadRadius: 30),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: colors.surface.withValues(alpha: colors.isDark ? 0.72 : 0.92),
            border: Border.all(
              color: colors.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : colors.accent.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: colors.isDark ? 0.08 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 24,
  });

  final Widget child;
  final Duration delay;
  final double offsetY;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    const animMs = 650;
    final totalMs = widget.delay.inMilliseconds + animMs;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );
    final start = widget.delay.inMilliseconds / totalMs;
    final interval = Interval(start, 1, curve: Curves.easeOutCubic);
    _fade = CurvedAnimation(parent: _controller, curve: interval);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: interval));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class PulseIcon extends StatefulWidget {
  const PulseIcon({super.key, required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              (widget.color ?? AppColors.accent).withValues(alpha: 0.25),
              AppColors.accentSecondary.withValues(alpha: 0.18),
            ],
          ),
          border: Border.all(
            color: (widget.color ?? AppColors.accent).withValues(alpha: 0.35),
          ),
        ),
        child: Icon(
          widget.icon,
          size: 34,
          color: widget.color ?? AppColors.accent,
        ),
      ),
    );
  }
}

class AnimatedScanFrame extends StatefulWidget {
  const AnimatedScanFrame({
    super.key,
    required this.width,
    required this.height,
    this.detected = false,
  });

  final double width;
  final double height;
  final bool detected;

  @override
  State<AnimatedScanFrame> createState() => _AnimatedScanFrameState();
}

class _AnimatedScanFrameState extends State<AnimatedScanFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.detected ? AppColors.accent : AppColors.accentSecondary;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor.withValues(alpha: widget.detected ? 0.95 : 0.55),
                width: 2.5,
              ),
              boxShadow: widget.detected
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 24,
                      ),
                    ]
                  : null,
            ),
          ),
          if (!widget.detected)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: 12,
                  right: 12,
                  top: 12 + (_controller.value * (widget.height - 36)),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.accent.withValues(alpha: 0.9),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.55),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ..._corners(borderColor),
        ],
      ),
    );
  }

  List<Widget> _corners(Color color) {
    const len = 22.0;
    const thick = 4.0;
    final corners = <Widget>[];

    for (final alignment in [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ]) {
      corners.add(
        Align(
          alignment: alignment,
          child: Container(
            width: len,
            height: len,
            decoration: BoxDecoration(
              border: Border(
                top: alignment.y < 0
                    ? BorderSide(color: color, width: thick)
                    : BorderSide.none,
                bottom: alignment.y > 0
                    ? BorderSide(color: color, width: thick)
                    : BorderSide.none,
                left: alignment.x < 0
                    ? BorderSide(color: color, width: thick)
                    : BorderSide.none,
                right: alignment.x > 0
                    ? BorderSide(color: color, width: thick)
                    : BorderSide.none,
              ),
            ),
          ),
        ),
      );
    }
    return corners;
  }
}

Route<T> fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class TiltWidget extends StatefulWidget {
  const TiltWidget({
    super.key,
    required this.child,
    this.maxTiltX = 0.12,
    this.maxTiltY = 0.12,
    this.padding,
    this.glowColor,
  });

  final Widget child;
  final double maxTiltX;
  final double maxTiltY;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;

  @override
  State<TiltWidget> createState() => _TiltWidgetState();
}

class _TiltWidgetState extends State<TiltWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _tiltXAnim;
  late final Animation<double> _tiltYAnim;

  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isTapping = false;
  double _shadowOffsetMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final localPosition = details.localPosition;
    final relX = (localPosition.dx / size.width) * 2 - 1;
    final relY = (localPosition.dy / size.height) * 2 - 1;

    setState(() {
      _tiltY = relX.clamp(-1.0, 1.0) * widget.maxTiltY;
      _tiltX = -relY.clamp(-1.0, 1.0) * widget.maxTiltX;
      _isTapping = true;
      _shadowOffsetMultiplier = 1.6;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _resetTilt();
  }

  void _resetTilt() {
    final startX = _tiltX;
    final startY = _tiltY;
    _tiltXAnim = Tween<double>(begin: startX, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _tiltYAnim = Tween<double>(begin: startY, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.addListener(() {
      setState(() {
        _tiltX = _tiltXAnim.value;
        _tiltY = _tiltYAnim.value;
        _shadowOffsetMultiplier = 1.0 + (1.0 - _controller.value) * 0.6;
      });
    });

    _controller.forward(from: 0).then((value) {
      _controller.removeListener(() {});
      setState(() {
        _isTapping = false;
        _shadowOffsetMultiplier = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    final isDark = colors.isDark;
    final glowColor = widget.glowColor ?? colors.accent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : 200.0,
          constraints.hasBoundedHeight ? constraints.maxHeight : 150.0,
        );
        return GestureDetector(
          onPanDown: (d) => setState(() {
            _isTapping = true;
            _shadowOffsetMultiplier = 1.6;
          }),
          onPanUpdate: (d) => _onPanUpdate(d, size),
          onPanEnd: _onPanEnd,
          onPanCancel: _resetTilt,
          child: AnimatedScale(
            scale: _isTapping ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015) // Perspective factor
                ..rotateX(_tiltX)
                ..rotateY(_tiltY),
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(
                        alpha: isDark
                            ? (0.12 * _shadowOffsetMultiplier)
                            : (0.08 * _shadowOffsetMultiplier),
                      ),
                      blurRadius: 28 * _shadowOffsetMultiplier,
                      offset: Offset(
                        _tiltY * 35 * _shadowOffsetMultiplier,
                        -_tiltX * 35 * _shadowOffsetMultiplier,
                      ),
                    ),
                  ],
                ),
                child: widget.padding != null
                    ? Padding(padding: widget.padding!, child: widget.child)
                    : widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
