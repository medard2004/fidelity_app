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

    // Fill in fullName and phone
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'Amina Kokou');
    await tester.enterText(textFields.at(1), '+228 90 12 34 56');
    await tester.pumpAndSettle();

    // Tap Date Picker
    final datePickerBtn = find.text("Sélectionner le jour, le mois et l'année");
    expect(datePickerBtn, findsOneWidget);
    await tester.tap(datePickerBtn);
    await tester.pumpAndSettle();

    // Tap OK on the Date Picker dialog
    final okBtn = find.text('OK');
    if (okBtn.evaluate().isNotEmpty) {
      await tester.tap(okBtn);
      await tester.pumpAndSettle();
    }

    // Tap "S'inscrire et vérifier mon numéro"
    final submitBtn = find.text("S'inscrire et vérifier mon numéro");
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify we navigated to the OTP Screen
    expect(find.text("Vérification"), findsOneWidget);

    // Type 6-digit OTP code
    final otpFields = find.byType(TextField);
    expect(otpFields, findsNWidgets(6));
    for (int i = 0; i < 6; i++) {
      await tester.enterText(otpFields.at(i), '1');
      await tester.pumpAndSettle();
    }

    // After OTP, we navigate to CompleteProfileScreen
    await tester.pumpAndSettle();
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
