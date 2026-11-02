// Screenshot renderer excerpt: uses synthetic fixtures; requires the private Flutter app.
// Imported widgets include app API types; do not use this excerpt against a live backend.
// Run from flutter_app: flutter test --no-pub ../demo/presentation-en-2026-11-01/render_demo_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dongle_me/api/api_client.dart';
import 'source/elder_home_view_en.dart';
import 'source/elder_status_en.dart';
import 'source/risk_score_cards_en.dart';
import 'package:dongle_me/theme/app_colors.dart';
import 'source/big_button_en.dart';

final outputDir = Platform.environment['DEMO_OUTPUT_DIR'] ?? 'demo-output';
const yIds = ['fall', 'cognitive_decline', 'depression', 'heart_failure', 'social_isolation'];
final dayStart = DateTime(2026, 11, 1).millisecondsSinceEpoch;
const normal = [0.18, 0.24, 0.21, 0.16, 0.28];
const attention = [0.58, 0.29, 0.43, 0.22, 0.48];

Map<String, dynamic> demoData(bool watch) {
  final values = watch ? attention : normal;
  return {
    'available': true,
    'dayStart': dayStart,
    'risks': {for (var i = 0; i < yIds.length; i++) yIds[i]: values[i]},
    'confidence_tiers': {for (final id in yIds) id: 'medium'},
    'bands': {for (var i = 0; i < yIds.length; i++) yIds[i]: values[i] >= 0.4 ? 'watch' : 'low'},
    'data_status': {for (final id in yIds) id: 'ok'},
    'confidence': {'low': false},
  };
}

Map<String, dynamic> demoHistory(bool watch) {
  const offsets = [0.03, 0.01, 0.025, -0.01, 0.01, -0.005, 0.0];
  return {
    'available': true,
    'days': [
      for (var d = 0; d < 7; d++)
        {
          'dayStart': dayStart - (6 - d) * 86400000,
          'risks': {
            for (var i = 0; i < yIds.length; i++)
              yIds[i]: watch && [0, 2, 4].contains(i)
                  ? normal[i] + (attention[i] - normal[i]) * d / 6
                  : (watch ? attention[i] : normal[i]) + offsets[d],
          },
        },
    ],
  };
}

ThemeData demoTheme() => ThemeData(
      useMaterial3: true,
      fontFamily: 'DemoLatin',
      fontFamilyFallback: const ['DemoChinese', 'DemoEmoji', 'DemoSymbols'],
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange, surface: AppColors.bgCream),
      scaffoldBackgroundColor: AppColors.bgCream,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 24, color: AppColors.inkSoft),
        bodyLarge: TextStyle(fontSize: 24, color: AppColors.ink),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(fontFamily: 'DemoLatin', fontSize: 22, color: AppColors.bgCream),
        behavior: SnackBarBehavior.floating,
      ),
    );

class DemoFrame extends StatelessWidget {
  const DemoFrame({required this.child, required this.role, super.key});
  final Widget child;
  final String role;

  @override
  Widget build(BuildContext context) => Material(
      color: AppColors.bgCream,
      child: DefaultTextStyle(
      style: const TextStyle(fontFamily: 'DemoLatin', fontFamilyFallback: ['DemoChinese', 'DemoEmoji', 'DemoSymbols'], color: AppColors.ink, decoration: TextDecoration.none),
      child: ColoredBox(
        color: AppColors.bgCream,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Row(children: [
              const Text('09:41', style: TextStyle(fontSize: 16, color: AppColors.ink, fontWeight: FontWeight.w700)),
              const Spacer(),
              const Icon(Icons.signal_cellular_alt_rounded, size: 18, color: AppColors.ink),
              const SizedBox(width: 5),
              const Icon(Icons.wifi_rounded, size: 18, color: AppColors.ink),
              const SizedBox(width: 5),
              const Icon(Icons.battery_full_rounded, size: 20, color: AppColors.ink),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
            child: Row(children: [
              Text('Dongle.me · $role', style: const TextStyle(fontSize: 15, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: .19), borderRadius: BorderRadius.circular(20)),
                child: const Text('DEMO · Synthetic', style: TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 6),
            child: Container(width: 110, height: 4, decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: .7), borderRadius: BorderRadius.circular(8))),
          ),
        ]),
      )));
}

class CaregiverDemo extends StatelessWidget {
  const CaregiverDemo({required this.watch, super.key});
  final bool watch;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bgCream,
        body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(32, 24, 32, 18),
              child: Text('Today’s reassurance', style: TextStyle(fontSize: 26, color: AppColors.inkSoft, fontWeight: FontWeight.w500)),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(color: AppColors.bgWarm, borderRadius: BorderRadius.circular(24)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppColors.statusOk, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.statusOk.withValues(alpha: .18), spreadRadius: 6)]),
                  ),
                  const SizedBox(width: 20),
                  const Text('All is well', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.ink)),
                ]),
                const SizedBox(height: 24),
                const Text('Last active', style: TextStyle(fontSize: 22, color: AppColors.inkSoft)),
                const SizedBox(height: 6),
                const Text('3 minutes ago', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 14),
                Text(watch ? 'Some recent trends deserve a friendly check-in.' : '4,862 steps today. Your parent has just checked in.', style: const TextStyle(fontSize: 17, height: 1.5, color: AppColors.inkSoft)),
              ]),
            ),
            const SizedBox(height: 22),
            RiskScoreCards(data: demoData(watch), history: demoHistory(watch)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: BigButton(onPressed: () {}, label: 'Call family', icon: Icons.phone_rounded, height: 100, fontSize: 48),
            ),
          ]),
        ),
      );
}

Future<void> loadFont(String family, String path) async {
  final loader = FontLoader(family);
  loader.addFont(Future.value(ByteData.sublistView(await File(path).readAsBytes())));
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Directory(outputDir).create(recursive: true);
    await loadFont('DemoLatin', Platform.environment['DEMO_LATIN_FONT'] ?? 'fonts/DejaVuSans.ttf');
    await loadFont('DemoChinese', Platform.environment['DEMO_CHINESE_FONT'] ?? 'fonts/SourceHanSansSC-Regular.otf');
    await loadFont('DemoSymbols', Platform.environment['DEMO_LATIN_FONT'] ?? 'fonts/DejaVuSans.ttf');
    await loadFont('DemoEmoji', Platform.environment['DEMO_EMOJI_FONT'] ?? 'fonts/NotoColorEmoji.ttf');
    await loadFont('MaterialIcons', Platform.environment['DEMO_ICONS_FONT'] ?? 'fonts/MaterialIcons-Regular.otf');
  });

  Future<void> capture(WidgetTester tester, String name, Size size, Widget child,
      {bool confirm = false, String role = 'Older adult', double ratio = 2.5}) async {
    tester.view.devicePixelRatio = ratio;
    tester.view.physicalSize = size * ratio;
    await tester.binding.setSurfaceSize(size);
    final key = GlobalKey();
    final messenger = GlobalKey<ScaffoldMessengerState>();
    Widget content = child;
    if (confirm) {
      content = ElderHomeView(
        steps: 4862, status: elderStatusFromSteps(4862),
        onImOk: () => messenger.currentState!.showSnackBar(const SnackBar(content: Text('Your family has received your check-in.'), duration: Duration(seconds: 30))),
        onHoldStart: () {}, onHoldClear: () {},
      );
    }
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messenger,
      theme: demoTheme(),
      home: RepaintBoundary(key: key, child: DemoFrame(role: role, child: content)),
    ));
    await tester.pumpAndSettle();
    if (confirm) {
      await tester.tap(find.text('I’m OK'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    }
    final error = tester.takeException();
    expect(error, isNull, reason: 'Presentation screenshot must not contain a layout error');
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: ratio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$outputDir/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('render both roles with exclusively synthetic presentation fixtures', (tester) async {
    final elder = ElderHomeView(steps: 4862, status: elderStatusFromSteps(4862), onImOk: () {}, onHoldStart: () {}, onHoldClear: () {});
    await capture(tester, '01-elder-home', const Size(432, 936), elder);
    await capture(tester, '02-elder-check-in', const Size(432, 936), elder, confirm: true);
    final folded = ElderHomeView(
      steps: 4862, status: elderStatusFromSteps(4862), activeMinutes: 126,
      week: const [
        DaySteps(date: '2026-10-25', steps: 2800), DaySteps(date: '2026-10-26', steps: 3600),
        DaySteps(date: '2026-10-27', steps: 3100), DaySteps(date: '2026-10-28', steps: 4200),
        DaySteps(date: '2026-10-29', steps: 3900), DaySteps(date: '2026-10-30', steps: 4600),
        DaySteps(date: '2026-10-31', steps: 4100),
      ], streak: 7,
      onImOk: () {}, onHoldStart: () {}, onHoldClear: () {},
    );
    await capture(tester, '03-elder-foldable', const Size(840, 900), folded, ratio: 2);
    await capture(tester, '04-caregiver-overview', const Size(432, 1900), const CaregiverDemo(watch: false), role: 'Family');
    await capture(tester, '05-caregiver-watch', const Size(432, 1900), const CaregiverDemo(watch: true), role: 'Family');
    await capture(tester, '06-caregiver-foldable', const Size(840, 1450), const CaregiverDemo(watch: false), role: 'Family', ratio: 2);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.binding.setSurfaceSize(null);
  });
}
