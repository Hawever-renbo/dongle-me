// PRESENTATION COPY ONLY: English localization concept. Production source is unchanged.
import 'package:flutter/material.dart';

import 'package:dongle_me/api/api_client.dart';
import 'package:dongle_me/common/screen_class.dart';
import 'package:dongle_me/theme/app_colors.dart';
import 'package:dongle_me/theme/tokens.dart';
import 'big_button_en.dart';
import 'elder_status_en.dart';

/// Pure presentation for the elder home. State/side-effects live in ElderHomePage;
/// this widget only lays out `steps` + `status` and forwards callbacks. Responsive:
/// compact (outer/cover screen) vs expanded (inner/unfolded).
class ElderHomeView extends StatelessWidget {
  const ElderHomeView({
    super.key,
    required this.steps,
    required this.status,
    required this.onImOk,
    required this.onHoldStart,
    required this.onHoldClear,
    this.activeMinutes,
    this.week,
    this.streak,
  });

  final int steps;
  final ElderStatus status;
  final VoidCallback onImOk;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldClear;
  final int? activeMinutes;
  final List<DaySteps>? week;
  final int? streak;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: AppSize.topWashHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.bgWarm, AppColors.bgCream],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return classifyScreen(constraints.maxWidth) == ScreenClass.expanded
                    ? _expanded()
                    : _compact();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hidden 3s-hold demo trigger lives on this label (pointer events forwarded up).
  Widget _stepsLabel() => Listener(
        onPointerDown: (_) => onHoldStart(),
        onPointerUp: (_) => onHoldClear(),
        onPointerCancel: (_) => onHoldClear(),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSize.labelDot,
              height: AppSize.labelDot,
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withAlpha(0x22),
                    blurRadius: 0,
                    spreadRadius: AppSize.labelDotHaloRing,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.labelGap),
            Text(
              'Today’s steps',
              style: TextStyle(
                fontSize: AppType.label,
                fontWeight: FontWeight.w500,
                color: AppColors.inkSoft,
                letterSpacing: AppType.label * AppLetter.label,
              ),
            ),
          ],
        ),
      );

  Widget _activeLabel() => Text(
        'Active today',
        style: TextStyle(
          fontSize: AppType.label,
          fontWeight: FontWeight.w500,
          color: AppColors.inkSoft,
          letterSpacing: AppType.label * AppLetter.label,
        ),
      );

  // Moderate-size panel value (half the compact hero) — two fit side by side.
  Widget _panelValue(String text) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: AppType.heroFallback * 0.5,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
            height: 1.0,
            letterSpacing: AppLetter.tight,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );

  Widget _panel({required Widget label, required String value, String? unit}) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            label,
            const SizedBox(height: AppSpacing.md),
            _panelValue(value),
            if (unit != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                unit,
                style: TextStyle(
                  fontSize: AppType.bodySoft,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkSoft,
                  letterSpacing: AppType.bodySoft * AppLetter.soft,
                ),
              ),
            ],
          ],
        ),
      );

  Widget _weekTrend() {
    final w = week;
    if (w == null || w.isEmpty) return const SizedBox.shrink();
    final maxSteps = w.map((d) => d.steps).fold(1, (a, b) => b > a ? b : a);
    return Column(
      key: const Key('elder-week-trend'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.xl), // gap above the trend; collapses with it when hidden
        Text('Last ${w.length} days',
            style: TextStyle(
              fontSize: AppType.label, fontWeight: FontWeight.w500,
              color: AppColors.inkSoft, letterSpacing: AppType.label * AppLetter.label,
            )),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final d in w)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 16,
                  height: 8 + 48 * (d.steps / maxSteps),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
        if ((streak ?? 0) > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('${streak}-day streak 🎉',
              style: TextStyle(
                fontSize: AppType.bodySoft, fontWeight: FontWeight.w500,
                color: AppColors.ink,
              )),
        ],
      ],
    );
  }

  Widget _statusLine() => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            status.emoji,
            style: TextStyle(fontSize: AppType.subtitle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            status.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppType.subtitle,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      );

  Widget _heroSteps() => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSize.heroMaxWidth),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatSteps(steps),
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontSize: AppType.heroFallback,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              letterSpacing: AppLetter.tight,
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      );

  Widget _stepsUnit() => Text(
        'steps',
        style: TextStyle(
          fontSize: AppType.bodySoft,
          fontWeight: FontWeight.w500,
          color: AppColors.inkSoft,
          letterSpacing: AppType.bodySoft * AppLetter.soft,
        ),
      );

  Widget _imOkBlock() => Column(
        children: [
          BigButton(onPressed: onImOk, label: 'I’m OK'),
          const SizedBox(height: AppSpacing.buttonToHelper),
          Text(
            'Tap to let your family know you’re doing well.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppType.helper,
              color: AppColors.inkSoft.withAlpha(0xD9),
              letterSpacing: AppType.helper * AppLetter.soft,
            ),
          ),
        ],
      );

  // —— compact (outer/cover screen): single column, glanceable ——
  Widget _compact() => Column(
        key: const Key('elder-compact'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
            child: Align(alignment: Alignment.centerLeft, child: _stepsLabel()),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statusLine(),
                  const SizedBox(height: AppSpacing.lg),
                  _heroSteps(),
                  const SizedBox(height: AppSpacing.heroToSubtitle),
                  _stepsUnit(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
            child: _imOkBlock(),
          ),
        ],
      );

  // —— expanded (inner/unfolded): more spacious, two-panel content column ——
  Widget _expanded() => Center(
        key: const Key('elder-expanded'),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.expandedMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusLine(),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _panel(label: _stepsLabel(), value: formatSteps(steps), unit: 'steps'),
                    _panel(label: _activeLabel(), value: formatActive(activeMinutes)),
                  ],
                ),
                _weekTrend(),
                const SizedBox(height: AppSpacing.xxl),
                _imOkBlock(),
              ],
            ),
          ),
        ),
      );
}

/// Thousands-separated step count (moved from ElderHomePage so the view owns it).
String formatSteps(int steps) {
  final s = steps.toString();
  if (s.length <= 3) return s;
  final out = <String>[];
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    out.insert(0, s[i]);
    count++;
    if (count == 3 && i > 0) {
      out.insert(0, ',');
      count = 0;
    }
  }
  return out.join();
}

/// Active-duration display: null → "—", <60min → "N 分钟", ≥60min → "H.h 小时".
String formatActive(int? minutes) {
  if (minutes == null) return '—';
  if (minutes < 60) return '$minutes min';
  return '${(minutes / 60).toStringAsFixed(1)} hours';
}
