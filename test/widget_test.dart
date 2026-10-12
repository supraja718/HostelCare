import 'package:flutter_test/flutter_test.dart';
import 'package:hostelcare/main.dart';

void main() {
  testWidgets('HostelCare app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('HostelCare'), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
  });
}
