import 'package:carte_app/main.dart';
import 'package:carte_app/features/wallet/widgets/loyalty_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Full flow to card detail screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: CarteApp()));
    await tester.pumpAndSettle();

    // Verify that onboarding starts with the first slide.
    expect(find.text("L'Écrin de vos Cartes"), findsOneWidget);

    // Tap "Passer" to go to Signup Screen
    final skipButton = find.text("Passer");
    expect(skipButton, findsOneWidget);
    await tester.tap(skipButton);
    await tester.pumpAndSettle();

    // Verify we navigated to the Signup screen.
    expect(find.text("Créer un compte"), findsOneWidget);

    // Fill in phone number
    final phoneField = find.byType(TextFormField);
    expect(phoneField, findsOneWidget);

    await tester.enterText(phoneField, '90 12 34 56');
    await tester.pumpAndSettle();

    // Tap "S'inscrire" (Direct signup without OTP)
    final submitBtn = find.text("S'inscrire");
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Direct navigation to CompleteProfileScreen
    expect(find.text("Complétez votre profil"), findsOneWidget);

    // Tap "Accéder à l'application"
    final accessBtn = find.text("Accéder à l'application");
    expect(accessBtn, findsOneWidget);
    await tester.ensureVisible(accessBtn);
    await tester.tap(accessBtn);
    await tester.pumpAndSettle();

    // Now we are on the Wallet Dashboard Screen
    expect(find.text("BONSOIR"), findsOneWidget);

    // Tap the first card in the stack
    final cardWidget = find.byType(LoyaltyCardWidget);
    expect(cardWidget, findsAtLeastNWidgets(1));
    await tester.tap(cardWidget.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify we are on CardDetailScreen
    expect(find.text("VOTRE CARTE"), findsOneWidget);
  });
}
