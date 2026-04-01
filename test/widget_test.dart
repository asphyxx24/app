import 'package:flutter_test/flutter_test.dart';
import 'package:mein_organizer/app.dart';

void main() {
  testWidgets('App startet und zeigt Dashboard', (tester) async {
    await tester.pumpWidget(const MeinOrganizerApp());
    expect(find.text('Mein Organizer'), findsOneWidget);
    expect(find.text('Karteikarten'), findsOneWidget);
  });
}
