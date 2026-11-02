// PRESENTATION COPY ONLY: English localization concept. Production source is unchanged.
/// A warm, non-clinical status for the elder's own view. Derived ONLY from today's
/// step count — deliberately NOT from risk_score (which is uncalibrated + caregiver-
/// facing). Reassurance only: never surfaces risk/alarm language.
class ElderStatus {
  final String emoji;
  final String message;
  const ElderStatus(this.emoji, this.message);
}

/// Gentle thresholds. Tuned conservatively; individual goals come later.
ElderStatus elderStatusFromSteps(int steps) {
  if (steps >= 2000) return const ElderStatus('😊', 'Looking good today');
  if (steps >= 500) return const ElderStatus('🙂', 'A little movement today');
  return const ElderStatus('🌱', 'A little walk feels good');
}
