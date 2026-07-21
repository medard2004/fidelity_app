// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:carte_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Onboarding flow smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CarteApp());
    await tester.pumpAndSettle();

    // Verify that onboarding starts with the first slide.
    expect(find.text("L'Écrin de vos Cartes"), findsOneWidget);
    expect(find.text("01 / 03"), findsOneWidget);

    // Tap the "Continuer" button.
    final nextButton = find.text("Continuer");
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    // Verify we are on the second slide.
    expect(find.text("Privilèges Uniques"), findsOneWidget);
    expect(find.text("02 / 03"), findsOneWidget);

    // Tap the "Continuer" button again.
    await tester.tap(find.text("Continuer"));
    await tester.pumpAndSettle();

    // Verify we are on the third slide.
    expect(find.text("Partager l'Élégance"), findsOneWidget);
    expect(find.text("03 / 03"), findsOneWidget);
    expect(find.text("Commencer l'expérience"), findsOneWidget);

    // Tap the "Commencer l'expérience" button.
    await tester.tap(find.text("Commencer l'expérience"));
    await tester.pumpAndSettle();

    // Verify we navigated to the signup page.
    expect(find.text("Prénom"), findsOneWidget);
  });
}
