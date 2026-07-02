import 'package:flutter_test/flutter_test.dart';

import 'package:drifter/main.dart';
import 'package:drifter/screens/splash_screen.dart';

void main() {
  testWidgets('App boots and shows the splash screen first', (
    WidgetTester tester,
  ) async {
    // Note: sqflite has no platform channel under `flutter test`'s VM, so
    // the splash screen's database lookup fails and is caught, falling back
    // to the home screen. This only verifies the widget tree mounts without
    // throwing; exercise the real flow with `flutter run` on a device.
    await tester.pumpWidget(const DrifterApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    // Flush the splash's minimum-duration timer so no timers are left
    // pending when the test ends.
    await tester.pump(const Duration(milliseconds: 750));
  });
}
