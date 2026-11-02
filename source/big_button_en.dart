// English presentation copy only: Latin-friendly letter spacing.
import 'package:flutter/material.dart';

import 'package:dongle_me/theme/app_colors.dart';
import 'package:dongle_me/theme/tokens.dart';

/// 主操作大按钮 — 温暖家庭风。
///
/// 来源：elder home "放心吧" 设计。第 2 次使用（caregiver "一键拨号"）触发抽取。
/// 提供可选 leading [icon]；默认尺寸/配色按 token 取，可单点覆写。
class BigButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final double? height;
  final double? fontSize;
  final Color? background;
  final Color? foreground;

  const BigButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.height,
    this.fontSize,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final double h = height ?? AppSize.bigButtonHeight;
    final double fs = fontSize ?? AppType.bigButton;
    final Color bg = background ?? AppColors.orange;
    final Color fg = foreground ?? AppColors.ink;
    return SizedBox(
      width: double.infinity,
      height: h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x38B85C2A),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x2DB85C2A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Center(
                // FittedBox prevents overflow when icon + text + letter
                // spacing exceeds container width (e.g. "一键拨号" + icon
                // at 76pt). Single line, 1.0 line height for vertical
                // centering precision.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: fs, color: fg),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: fs,
                          fontWeight: FontWeight.w800,
                          color: fg,
                          letterSpacing: 0.5,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
