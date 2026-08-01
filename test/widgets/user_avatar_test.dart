import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carte_app/widgets/shared/user_avatar.dart';

void main() {
  testWidgets('shows initials when photoUrl is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UserAvatar(fullName: 'Ada Lovelace')),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows a network image when photoUrl is set', (tester) async {
    // pump() only, never pumpAndSettle(): the image never actually resolves
    // in the test sandbox (no network), we only assert the widget is present.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatar(
            fullName: 'Ada Lovelace',
            photoUrl: 'https://example.com/avatar.jpg',
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('shows a spinner when isLoading is true', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatar(fullName: 'Ada Lovelace', isLoading: true),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
