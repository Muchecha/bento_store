import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';

class AnimatedChangeDisplay extends StatefulWidget {
  final double change;

  const AnimatedChangeDisplay({super.key, required this.change});

  @override
  State<AnimatedChangeDisplay> createState() => _AnimatedChangeDisplayState();
}

class _AnimatedChangeDisplayState extends State<AnimatedChangeDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _valueAnimation;

  double _previousChange = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _valueAnimation = Tween<double>(
      begin: 0.0,
      end: widget.change,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedChangeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.change != widget.change) {
      _previousChange = oldWidget.change;
      _valueAnimation = Tween<double>(
        begin: _previousChange,
        end: widget.change,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = widget.change >= 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.surfaceColor,
                AppTheme.surfaceColor.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(color: AppTheme.textColor),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Troco',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textColor.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Text(
                        '${isPositive ? '' : '-'} ${FormatUtils.formatCurrency(_valueAnimation.value)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              isPositive
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.change_circle_rounded,
                size: 32.sp,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
