import 'package:flutter/material.dart';

class AppSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.shape == BoxShape.circle
        ? null
        : widget.borderRadius ?? BorderRadius.circular(16);

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final animationValue = _controller.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: widget.shape,
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment(-1.8 + (animationValue * 2), -0.3),
                end: Alignment(1.2 + (animationValue * 2), 0.3),
                colors: const [
                  Color(0xFFE2E8F0),
                  Color(0xFFF8FAFC),
                  Color(0xFFE2E8F0),
                ],
                stops: const [0.2, 0.5, 0.8],
              ),
            ),
          );
        },
      ),
    );
  }
}
