import "package:flutter_test/flutter_test.dart";
import "package:tracemate/main.dart";

void main() {
  testWidgets("TraceMate smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(const TraceMateApp());
    await tester.pump();
    expect(find.text("TraceMate"), findsOneWidget);
  });
}
