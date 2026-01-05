import 'package:flutter_test/flutter_test.dart';
import 'package:hydro_guard_app/main.dart'; // നിങ്ങളുടെ പ്രോജക്ട് പേര് ഉറപ്പുവരുത്തുക

void main() {
  testWidgets('Hydro Guard Pro Home Screen Test', (WidgetTester tester) async {
    // ആപ്പ് ബിൽഡ് ചെയ്യുന്നു
    await tester.pumpWidget(const HydroGuardApp());

    // ഹോം പേജിൽ 'Hydro Guard Pro' എന്ന ടെക്സ്റ്റ് ഉണ്ടോ എന്ന് പരിശോധിക്കുന്നു
    expect(find.text('HYDRO GUARD PRO'), findsWidgets);
  });
}
