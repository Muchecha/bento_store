import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuccessIcon extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const SuccessIcon({
    super.key,
    this.size = 80,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<SuccessIcon> createState() => _SuccessIcon();
}

class _SuccessIcon extends State<SuccessIcon> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _checkController.forward();
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size.w,
        height: widget.size.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.backgroundColor ?? Colors.green.shade400,
              widget.backgroundColor?.withValues(alpha: 0.8) ??
                  Colors.green.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (widget.backgroundColor ?? Colors.green).withValues(
                alpha: 0.3,
              ),
              blurRadius: 10,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _checkAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: CheckmarkPainter(
                progress: _checkAnimation.value,
                color: widget.iconColor ?? Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 4.w
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    final startPoint = Offset(center.dx - 12.w, center.dy);
    final middlePoint = Offset(center.dx - 2.w, center.dy + 8.w);
    final endPoint = Offset(center.dx + 12.w, center.dy - 8.w);

    if (progress <= 0.5) {
      final currentProgress = progress * 2;
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(
        startPoint.dx + (middlePoint.dx - startPoint.dx) * currentProgress,
        startPoint.dy + (middlePoint.dy - startPoint.dy) * currentProgress,
      );
    } else {
      final currentProgress = (progress - 0.5) * 2;
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(middlePoint.dx, middlePoint.dy);
      path.lineTo(
        middlePoint.dx + (endPoint.dx - middlePoint.dx) * currentProgress,
        middlePoint.dy + (endPoint.dy - middlePoint.dy) * currentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
