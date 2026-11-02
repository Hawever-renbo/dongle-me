// PRESENTATION COPY ONLY: English localization concept. Production source is unchanged.
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:dongle_me/common/screen_class.dart';
import 'package:dongle_me/config.dart';
import 'package:dongle_me/theme/app_colors.dart';
import 'package:dongle_me/theme/tokens.dart';

/// R7 — 5 independent Y risk cards (IB-v4 §14.5 Pareto, no overall risk).
///
/// Inputs come from GET /caregiver/risk_score/:familyId:
///   risks:            { y_id: probability ∈ [0,1] | null }
///   confidence_tiers: { y_id: 'high' | 'medium' | 'low_data' }
///
/// Display contract:
///   - probability ≠ null → progress bar + tier badge + percentage
///   - probability  = null → grey card with "数据补全中" message
///   - social_isolation low_data → specifically marked "待 Phase 4 (GPS / 通话记录)"
///     so caregiver understands this isn't a system bug but a known limitation.
class RiskScoreCards extends StatefulWidget {
  const RiskScoreCards({
    super.key,
    required this.data,
    this.history,
  });

  /// Raw response body from /caregiver/risk_score/:familyId, or null if not loaded yet.
  /// Expected keys: available, risks, confidence_tiers, basin_distances, dayStart.
  final Map<String, dynamic>? data;

  /// Raw response body from /caregiver/risk_history/:familyId?days=7.
  /// Expected keys: available, n_days, days[{dayStart, risks, confidence_tiers}].
  /// null = not loaded yet → cards render without sparklines (back-compat).
  final Map<String, dynamic>? history;

  @override
  State<RiskScoreCards> createState() => _RiskScoreCardsState();
}

class _RiskScoreCardsState extends State<RiskScoreCards> {
  // B1: track which dayStart the user has given feedback on, so we hide
  // the buttons after one submission per day. Local-only state (no persistence
  // across app restart — backend has the audit log).
  String? _ackedDayKey;
  bool _submitting = false;

  Future<void> _submitFeedback(String verdict, int? dayStart) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await Dio().post(
        '${AppConfig.cloudBaseUrl}/risk_score/feedback',
        data: {
          'familyId': AppConfig.familyId,
          'alert_ts': dayStart ?? DateTime.now().millisecondsSinceEpoch,
          'verdict': verdict,
        },
      );
      if (!mounted) return;
      setState(() {
        _ackedDayKey = dayStart?.toString() ?? 'today';
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verdict == 'elder_ok' ? 'Saved: doing well' : 'Saved: a concern'),
          backgroundColor: verdict == 'elder_ok'
              ? AppColors.statusOk
              : AppColors.statusWarn,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    }
  }

  static const _yOrder = [
    'fall',
    'cognitive_decline',
    'depression',
    'heart_failure',
    'social_isolation',
  ];

  static const _yLabels = {
    'fall': 'Fall risk',
    'cognitive_decline': 'Cognitive decline',
    'depression': 'Depressive tendency',
    'heart_failure': 'Heart failure signs',
    'social_isolation': 'Social isolation',
  };

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      return const SizedBox.shrink();
    }
    if (widget.data!['available'] == false) {
      return _UnavailableNote(reason: (widget.data!['reason'] as String?) ?? 'No estimate yet');
    }

    final risks = (widget.data!['risks'] as Map?)?.cast<String, dynamic>() ?? const {};
    final tiers = (widget.data!['confidence_tiers'] as Map?)?.cast<String, dynamic>() ?? const {};
    final bands = (widget.data!['bands'] as Map?)?.cast<String, dynamic>() ?? const {};
    final dataStatus = (widget.data!['data_status'] as Map?)?.cast<String, dynamic>() ?? const {};
    // ④ confidence gate — a per-fire flag; on low_confidence days every card hides its band.
    final confLow = ((widget.data!['confidence'] as Map?)?['low'] as bool?) ?? false;
    final dayStart = widget.data!['dayStart'] as int?;
    final dayKey = dayStart?.toString() ?? 'today';
    final acked = _ackedDayKey == dayKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                'Health trends',
                style: TextStyle(
                  fontSize: AppType.subtitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: AppType.subtitle * AppLetter.label,
                ),
              ),
              if (dayStart != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatDay(dayStart),
                  style: TextStyle(
                    fontSize: AppType.helper,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ],
          ),
        ),
        // R7 + 5-21 user feedback: disclaimer banner.
        // The probability numbers below are sigmoid-mapped logits from a
        // literature OR/HR model on a 7-day rolling baseline. They are NOT
        // clinical diagnosis. Caregivers shown a "78% fall risk" without this
        // context tend to over-react → trust erosion. This banner stays
        // until Phase 5+ post-calibration ships.
        const _DisclaimerBanner(),
        LayoutBuilder(
          builder: (context, constraints) {
            Widget cardFor(String y) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _RiskCard(
                    yId: y,
                    label: _yLabels[y]!,
                    probability:
                        risks[y] is num ? (risks[y] as num).toDouble() : null,
                    tier: (tiers[y] as String?) ?? 'low_data',
                    band: bands[y] as String?,
                    dataStatus: (dataStatus[y] as String?) ?? 'ok',
                    confidenceLow: confLow,
                    sparkline: _extractSparkline(y),
                  ),
                );
            final twoCol =
                classifyScreen(constraints.maxWidth) == ScreenClass.expanded;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: twoCol
                  ? Row(
                      key: const Key('risk-cards-two-col'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              for (final i in [0, 2, 4]) cardFor(_yOrder[i]),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            children: [
                              for (final i in [1, 3]) cardFor(_yOrder[i]),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const Key('risk-cards-single'),
                      children: [
                        for (final y in _yOrder) cardFor(y),
                      ],
                    ),
            );
          },
        ),
        // B1: caregiver feedback buttons. One row, single-tap-per-day.
        // Feeds Phase 2 self_prediction scorer as label data. After tap, hide
        // until next day (dayStart changes).
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: acked
              ? Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.statusOk.withAlpha(0x1A),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 18, color: AppColors.statusOk),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Thanks. Your feedback is saved.',
                        style: TextStyle(
                          fontSize: AppType.helper,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'How is your parent today?',
                      style: TextStyle(
                        fontSize: AppType.helper + 1,
                        color: AppColors.inkSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _FeedbackButton(
                            label: 'They’re doing well',
                            icon: Icons.thumb_up_outlined,
                            color: AppColors.statusOk,
                            enabled: !_submitting,
                            onTap: () => _submitFeedback('elder_ok', dayStart),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _FeedbackButton(
                            label: 'Something is wrong',
                            icon: Icons.warning_amber_outlined,
                            color: AppColors.statusWarn,
                            enabled: !_submitting,
                            onTap: () => _submitFeedback('elder_concern', dayStart),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  String _formatDay(int dayStartMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(dayStartMs);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  /// B5 — pull per-Y last-N-days probability array from history JSON.
  /// Returns null when history not loaded OR fewer than 2 points.
  /// Null values in the series are kept as null so sparkline can draw gaps.
  List<double?>? _extractSparkline(String yId) {
    final h = widget.history;
    if (h == null || h['available'] != true) return null;
    final days = h['days'] as List?;
    if (days == null || days.length < 2) return null;
    final series = <double?>[];
    for (final d in days) {
      if (d is Map) {
        final risks = (d['risks'] as Map?) ?? const {};
        final v = risks[yId];
        series.add(v is num ? v.toDouble() : null);
      }
    }
    return series;
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({
    required this.yId,
    required this.label,
    required this.probability,
    required this.tier,
    this.band,
    this.dataStatus = 'ok',
    this.confidenceLow = false,
    this.sparkline,
  });

  final String yId;
  final String label;
  final double? probability;
  final String tier;
  final String? band;       // ② low | watch | concern (from cloud); null on old data
  final String dataStatus;  // ③ ok | accumulating
  final bool confidenceLow; // ④ low-confidence day (thin/phone-dark/fresh baseline) → suppress band

  /// Last-N-days probability series for this Y (null entries = no data that day).
  /// null = no history available → card renders without sparkline.
  final List<double?>? sparkline;

  // ④ A low-confidence day scores off a data-quality artifact, not real behavior — render it
  // like "no data" (hide the band/%) so the caregiver never sees a number that jitters day to day.
  bool get _isNull => probability == null || confidenceLow;

  // ② band drives color + headline. Fall back to deriving from probability for
  // events that predate the banded model (backward compat).
  String? get _effectiveBand {
    if (band != null) return band;
    if (probability == null) return null;
    final p = probability!;
    return p >= 0.7 ? 'concern' : (p >= 0.4 ? 'watch' : 'low');
  }

  String get _bandLabel {
    switch (_effectiveBand) {
      case 'concern':
        return 'Needs attention';
      case 'watch':
        return 'Watch';
      case 'low':
        return 'Stable';
      default:
        return '—';
    }
  }

  Color get _accentColor {
    switch (_effectiveBand) {
      case 'concern':
        return AppColors.statusAlert;
      case 'watch':
        return AppColors.statusWarn;
      case 'low':
        return AppColors.statusOk;
      default:
        return AppColors.wood.withAlpha(0x66);
    }
  }

  String get _tierBadgeText {
    switch (tier) {
      case 'high':
        return 'Higher confidence';
      case 'medium':
        return 'Moderate';
      case 'low_data':
      default:
        return 'More data needed';
    }
  }

  String get _nullMessage {
    if (confidenceLow && dataStatus != 'accumulating') {
      return 'Not enough reliable observations today to show an estimate.';
    }
    if (dataStatus == 'accumulating') {
      return 'Building a baseline. Trends appear after about one week.';
    }
    if (yId == 'social_isolation') {
      return 'More observations needed for this estimate.';
    }
    return 'Not enough usable observations.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _isNull ? AppColors.bgWarm.withAlpha(0x88) : AppColors.bgWarm,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: _accentColor.withAlpha(0x55),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              _TierBadge(text: _tierBadgeText, color: _accentColor),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_isNull)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _nullMessage,
                style: TextStyle(
                  fontSize: AppType.helper,
                  color: AppColors.inkSoft,
                  height: 1.4,
                ),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // ② band word is the headline (coarse, de-alarming); precise %
                // is demoted to a small "参考" reference since it isn't calibrated.
                Text(
                  _bandLabel,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: _accentColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    'Reference score · ${(probability! * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: AppType.helper,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: probability!.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.wood.withAlpha(0x33),
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
              ),
            ),
            // B5 — 7-day sparkline of probability trend, when history available.
            // §14.6: acute (Δ today vs yesterday) + chronic (7d drift) only
            // visible when caregiver sees the trend, not the single number.
            if (sparkline != null && sparkline!.length >= 2) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    '${sparkline!.length} days',
                    style: TextStyle(
                      fontSize: AppType.helper - 2,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SizedBox(
                      height: 22,
                      child: CustomPaint(
                        painter: _SparklinePainter(
                          values: sparkline!,
                          color: _accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(0x22),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.wood.withAlpha(0x1A),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border(
            left: BorderSide(color: AppColors.wood, width: 4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: AppColors.inkSoft,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Research estimate, not a diagnosis',
                    style: TextStyle(
                      fontSize: AppType.helper + 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Scores reflect changes from a recent 7-day baseline. Follow the trend; a single high score is not a diagnosis.',
                    style: TextStyle(
                      fontSize: AppType.helper - 1,
                      color: AppColors.inkSoft,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// B5 — minimal sparkline painter for the 7-day per-Y probability trend.
/// Renders: faint horizontal baseline at y=0.5, polyline through values,
/// last point marked with a filled circle, null entries cause gaps.
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double?> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    // baseline at 50%
    final baselinePaint = Paint()
      ..color = AppColors.wood.withAlpha(0x44)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final midY = size.height / 2;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), baselinePaint);

    final n = values.length;
    final stepX = size.width / (n - 1);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()..color = color;

    Path? current;
    for (int i = 0; i < n; i++) {
      final v = values[i];
      if (v == null) {
        // close current segment; gap
        if (current != null) {
          canvas.drawPath(current, linePaint);
          current = null;
        }
        continue;
      }
      final x = stepX * i;
      // map probability [0,1] → y. y=0 at top (high risk), y=size.height at bottom.
      // Invert so high prob renders high on the sparkline (intuitively "up = worse").
      final y = size.height - (v.clamp(0.0, 1.0) * size.height);
      if (current == null) {
        current = Path()..moveTo(x, y);
      } else {
        current.lineTo(x, y);
      }
      if (i == n - 1) {
        // last point dot
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }
    if (current != null) canvas.drawPath(current, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.color != color || !_listEq(old.values, values);

  bool _listEq(List<double?> a, List<double?> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(0x14),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withAlpha(0x55), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: AppType.helper + 2,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableNote extends StatelessWidget {
  const _UnavailableNote({required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgWarm.withAlpha(0x66),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          'Health trends评估\n$reason',
          style: TextStyle(
            fontSize: AppType.helper,
            color: AppColors.inkSoft,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
