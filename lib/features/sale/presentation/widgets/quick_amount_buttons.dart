import 'package:bento_store/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/format_utils.dart';

class MultiSelectQuickAmountButtons extends StatefulWidget {
  final Function(double amount, int quantity) onAmountSelected;
  final Function(double totalAmount)? onTotalChanged;
  final List<double>? customAmounts;
  final Map<double, int>? initialSelections;
  final bool enableHapticFeedback;
  final EdgeInsetsGeometry? padding;
  final int maxSelectionPerAmount;
  final bool showTotalAmount;

  const MultiSelectQuickAmountButtons({
    super.key,
    required this.onAmountSelected,
    this.onTotalChanged,
    this.customAmounts,
    this.initialSelections,
    this.enableHapticFeedback = true,
    this.padding,
    this.maxSelectionPerAmount = 10,
    this.showTotalAmount = true,
  });

  @override
  State<MultiSelectQuickAmountButtons> createState() =>
      _MultiSelectQuickAmountButtonsState();
}

class _MultiSelectQuickAmountButtonsState
    extends State<MultiSelectQuickAmountButtons> {
  late Map<double, int> _selectedAmounts;

  static const List<double> _defaultAmounts = [5, 10, 20, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _selectedAmounts = Map<double, int>.from(widget.initialSelections ?? {});
  }

  List<double> get _amounts => widget.customAmounts ?? _defaultAmounts;

  double get _totalAmount {
    return _selectedAmounts.entries
        .map((entry) => entry.key * entry.value)
        .fold(0.0, (sum, amount) => sum + amount);
  }

  void _handleAmountSelection(double amount) {
    final currentCount = _selectedAmounts[amount] ?? 0;

    if (currentCount < widget.maxSelectionPerAmount) {
      setState(() {
        _selectedAmounts[amount] = currentCount + 1;
      });

      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }

      widget.onAmountSelected(amount, _selectedAmounts[amount]!);
      widget.onTotalChanged?.call(_totalAmount);
    } else {
      // Feedback quando atingir o limite
      if (widget.enableHapticFeedback) {
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _handleAmountDecrease(double amount) {
    final currentCount = _selectedAmounts[amount] ?? 0;

    if (currentCount > 0) {
      setState(() {
        if (currentCount == 1) {
          _selectedAmounts.remove(amount);
        } else {
          _selectedAmounts[amount] = currentCount - 1;
        }
      });

      if (widget.enableHapticFeedback) {
        HapticFeedback.selectionClick();
      }

      widget.onAmountSelected(amount, _selectedAmounts[amount] ?? 0);
      widget.onTotalChanged?.call(_totalAmount);
    }
  }

  void _clearAllSelections() {
    setState(() {
      _selectedAmounts.clear();
    });

    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    widget.onTotalChanged?.call(0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valores Rápidos',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_selectedAmounts.isNotEmpty)
                GestureDetector(
                  onTap: _clearAllSelections,
                  child: Row(
                    children: [
                      Icon(
                        Icons.clear_all_rounded,
                        size: 14.sp,
                        color: AppTheme.errorColor,
                      ),
                      Text(
                        'Limpar',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          _AmountGrid(
            amounts: _amounts,
            selectedAmounts: _selectedAmounts,
            onAmountSelected: _handleAmountSelection,
            onAmountDecrease: _handleAmountDecrease,
            maxSelectionPerAmount: widget.maxSelectionPerAmount,
          ),
          if (widget.showTotalAmount) ...[
            SizedBox(height: 12.h),
            _TotalAmountDisplay(totalAmount: _totalAmount),
          ],
        ],
      ),
    );
  }
}

class _AmountGrid extends StatelessWidget {
  final List<double> amounts;
  final Map<double, int> selectedAmounts;
  final ValueChanged<double> onAmountSelected;
  final ValueChanged<double> onAmountDecrease;
  final int maxSelectionPerAmount;

  const _AmountGrid({
    required this.amounts,
    required this.selectedAmounts,
    required this.onAmountSelected,
    required this.onAmountDecrease,
    required this.maxSelectionPerAmount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: amounts.length,
      itemBuilder: (context, index) {
        final amount = amounts[index];
        final count = selectedAmounts[amount] ?? 0;
        return _MultiSelectAmountButton(
          amount: amount,
          count: count,
          maxCount: maxSelectionPerAmount,
          onTap: () => onAmountSelected(amount),
          onLongPress: () => onAmountDecrease(amount),
        );
      },
    );
  }
}

class _MultiSelectAmountButton extends StatelessWidget {
  final double amount;
  final int count;
  final int maxCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _MultiSelectAmountButton({
    required this.amount,
    required this.count,
    required this.maxCount,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = count > 0;
    final isMaxReached = count >= maxCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: isSelected ? 4.0 : 1.0,
          borderRadius: BorderRadius.circular(12.r),
          color:
              isSelected
                  ? (isMaxReached
                      ? colorScheme.errorContainer
                      : AppTheme.secondaryColor)
                  : colorScheme.surface,
          shadowColor:
              isSelected
                  ? (isMaxReached
                      ? colorScheme.error.withValues(alpha: 0.3)
                      : AppTheme.secondaryColor.withValues(alpha: 0.3))
                  : colorScheme.shadow.withValues(alpha: 0.1),
          child: InkWell(
            onTap: onTap,
            onLongPress: isSelected ? onLongPress : null,
            borderRadius: BorderRadius.circular(12.r),
            splashColor: (isMaxReached
                    ? colorScheme.error
                    : AppTheme.secondaryColor)
                .withValues(alpha: 0.1),
            highlightColor: (isMaxReached
                    ? colorScheme.error
                    : AppTheme.secondaryColor)
                .withValues(alpha: 0.05),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color:
                      isSelected
                          ? (isMaxReached
                              ? colorScheme.error
                              : AppTheme.secondaryColor)
                          : AppTheme.secondaryColor.withValues(alpha: 0.3),
                  width: isSelected ? 2.0 : 1.0,
                ),
                gradient:
                    isSelected
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            isMaxReached
                                ? colorScheme.errorContainer
                                : AppTheme.secondaryColor,
                            (isMaxReached
                                    ? colorScheme.errorContainer
                                    : AppTheme.secondaryColor)
                                .withValues(alpha: 0.8),
                          ],
                        )
                        : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      FormatUtils.formatCurrencyWithSymbol(amount),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color:
                            isSelected
                                ? (isMaxReached
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onPrimaryContainer)
                                : colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Toque longo para remover',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 9.sp,
                          color: (isMaxReached
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onPrimaryContainer)
                              .withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            top: -8.h,
            right: -8.w,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color:
                    isMaxReached ? colorScheme.error : AppTheme.secondaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isMaxReached
                            ? colorScheme.error
                            : AppTheme.secondaryColor)
                        .withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${count}x',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      isMaxReached
                          ? colorScheme.onError
                          : colorScheme.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TotalAmountDisplay extends StatelessWidget {
  final double totalAmount;

  const _TotalAmountDisplay({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryColor,
            AppTheme.secondaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
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
                'Total Selecionado',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                FormatUtils.formatCurrencyWithSymbol(totalAmount),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 32.sp,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
