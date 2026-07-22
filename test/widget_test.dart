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

    // Tap "Passer" to go straight to Auth Screen
    final skipButton = find.text("Passer");
    expect(skipButton, findsOneWidget);
    await tester.tap(skipButton);
    await tester.pumpAndSettle();

    // Verify we navigated to the Auth screen.
    expect(find.text("Numéro de téléphone"), findsOneWidget);

    // Tap "Continuer" on Auth Screen
    final continueBtn = find.text("Continuer");
    expect(continueBtn, findsOneWidget);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Verify we navigated to the OTP Screen
    expect(find.text("Vérification"), findsOneWidget);

    // Type OTP code
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(6));
    for (int i = 0; i < 6; i++) {
      await tester.enterText(textFields.at(i), '1');
      await tester.pumpAndSettle();
    }

    // After typing 6 digits, we should be on QrScanScreen.
    // QrScanScreen has a timer of 2 seconds to redirect to JoinRestaurantScreen.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Now we should be on JoinRestaurantScreen.
    expect(find.text("Rejoindre Chez Awa"), findsOneWidget);

    // Tap "Rejoindre le programme"
    final joinBtn = find.text("Rejoindre le programme");
    expect(joinBtn, findsOneWidget);
    await tester.tap(joinBtn);
    
    // It has a delay of 900ms then redirects to /wallet
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Now we are on the Wallet Dashboard Screen
    expect(find.text("BONSOIR"), findsOneWidget);

    // Let's tap the first card in the stack
    final cardWidget = find.byType(LoyaltyCardWidget);
    expect(cardWidget, findsAtLeastNWidgets(1));
    await tester.tap(cardWidget.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify we are on CardDetailScreen
    expect(find.text("VOTRE CARTE"), findsOneWidget);
  });
}
