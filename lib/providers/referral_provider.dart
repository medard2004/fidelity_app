import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_card.dart';
import '../data/mock_data.dart';

/// Enregistrement d'une invitation envoyée
class ReferralRecord {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String recipient;
  final DateTime timestamp;
  final bool isValidatedClick; // Vrai si un clic unique a été confirmé côté serveur
  final bool isDuplicate;       // Vrai si le destinataire a déjà été sollicité
  final String fraudNote;      // Ex. "Clic unique vérifié", "Destinataire déjà invité"

  const ReferralRecord({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.recipient,
    required this.timestamp,
    required this.isValidatedClick,
    required this.isDuplicate,
    required this.fraudNote,
  });
}

/// État du système de parrainage par restaurant
class ReferralState {
  final String selectedRestaurantId;
  final String customMessage;
  final List<String> recipients;
  final List<ReferralRecord> records;
  final int totalUniqueShares; // Nombre de partages uniques validés

  const ReferralState({
    required this.selectedRestaurantId,
    required this.customMessage,
    required this.recipients,
    required this.records,
    required this.totalUniqueShares,
  });

  /// Calcul des points selon la règle : 100 partages valides = 3 points
  int get pointsEarned => (totalUniqueShares ~/ 100) * 3;

  /// Partages restants pour le prochain palier de 3 points (sur 100)
  int get sharesToNextReward => 100 - (totalUniqueShares % 100);

  /// Ratio de progression vers les prochains 3 points (0.0 à 1.0)
  double get progressRatio => (totalUniqueShares % 100) / 100.0;

  ReferralState copyWith({
    String? selectedRestaurantId,
    String? customMessage,
    List<String>? recipients,
    List<ReferralRecord>? records,
    int? totalUniqueShares,
  }) {
    return ReferralState(
      selectedRestaurantId: selectedRestaurantId ?? this.selectedRestaurantId,
      customMessage: customMessage ?? this.customMessage,
      recipients: recipients ?? this.recipients,
      records: records ?? this.records,
      totalUniqueShares: totalUniqueShares ?? this.totalUniqueShares,
    );
  }
}

class ReferralNotifier extends StateNotifier<ReferralState> {
  ReferralNotifier()
      : super(
          ReferralState(
            selectedRestaurantId: MockData.cards.first.id,
            customMessage:
                'Découvre ${MockData.cards.first.restaurantName} et profite de l\'offre de bienvenue réservée sur l\'application !',
            recipients: const [],
            records: [
              // Exemples initiaux pour illustrer le système anti-fraude
              ReferralRecord(
                id: 'r1',
                restaurantId: 'card_comptoir',
                restaurantName: 'Bistrot de Quartier',
                recipient: '+228 90 11 22 33',
                timestamp: DateTime.now().subtract(const Duration(hours: 4)),
                isValidatedClick: true,
                isDuplicate: false,
                fraudNote: 'Clic unique vérifié',
              ),
              ReferralRecord(
                id: 'r2',
                restaurantId: 'card_comptoir',
                restaurantName: 'Bistrot de Quartier',
                recipient: '+228 90 11 22 33',
                timestamp: DateTime.now().subtract(const Duration(hours: 2)),
                isValidatedClick: false,
                isDuplicate: true,
                fraudNote: 'Destinataire en doublon (Rejeté)',
              ),
            ],
            totalUniqueShares: 42, // Exemple de départ (42 partages uniques)
          ),
        );

  /// Change le restaurant partenaire sélectionné et adapte le message par défaut
  void selectRestaurant(LoyaltyCard card) {
    state = state.copyWith(
      selectedRestaurantId: card.id,
      customMessage:
          'Découvre ${card.restaurantName} et profite de : "${card.welcomeOffer}" !',
    );
  }

  /// Met à jour le message personnalisé
  void updateMessage(String message) {
    state = state.copyWith(customMessage: message);
  }

  /// Ajoute un destinataire s'il n'est pas déjà dans la liste temporaire
  bool addRecipient(String recipient) {
    final clean = recipient.trim();
    if (clean.isEmpty || state.recipients.contains(clean)) return false;
    state = state.copyWith(recipients: [...state.recipients, clean]);
    return true;
  }

  /// Supprime un destinataire de la liste temporaire
  void removeRecipient(String recipient) {
    state = state.copyWith(
      recipients: state.recipients.where((r) => r != recipient).toList(),
    );
  }

  /// Vide la liste des destinataires
  void clearRecipients() {
    state = state.copyWith(recipients: const []);
  }

  /// Exécute l'envoi du parrainage avec le MOTEUR ANTI-FRAUDE :
  /// 1. Élimine les doublons de destinataires déjà contactés pour ce restaurant.
  /// 2. Simule la vérification du clic unique côté serveur pour chaque envoi valide.
  /// 3. Incrémente le compteur de partages uniques d'autant de nouveaux partages valides.
  Map<String, dynamic> sendReferrals(LoyaltyCard card) {
    if (state.recipients.isEmpty) {
      return {'success': false, 'addedCount': 0, 'duplicateCount': 0};
    }

    final newRecords = <ReferralRecord>[];
    int addedValidCount = 0;
    int duplicateCount = 0;

    // Obtenir la liste des destinataires déjà enregistrés pour CE restaurant
    final existingForRestaurant = state.records
        .where((r) => r.restaurantId == card.id)
        .map((r) => r.recipient.toLowerCase())
        .toSet();

    for (final recipient in state.recipients) {
      final isDup = existingForRestaurant.contains(recipient.toLowerCase());
      if (isDup) {
        duplicateCount++;
        newRecords.add(
          ReferralRecord(
            id: 'r_${DateTime.now().millisecondsSinceEpoch}_$duplicateCount',
            restaurantId: card.id,
            restaurantName: card.restaurantName,
            recipient: recipient,
            timestamp: DateTime.now(),
            isValidatedClick: false,
            isDuplicate: true,
            fraudNote: 'Doublon détecté (Non comptabilisé)',
          ),
        );
      } else {
        addedValidCount++;
        existingForRestaurant.add(recipient.toLowerCase());
        newRecords.add(
          ReferralRecord(
            id: 'r_${DateTime.now().millisecondsSinceEpoch}_$addedValidCount',
            restaurantId: card.id,
            restaurantName: card.restaurantName,
            recipient: recipient,
            timestamp: DateTime.now(),
            isValidatedClick: true, // Clic unique validé par le système anti-fraude
            isDuplicate: false,
            fraudNote: 'Clic unique validé',
          ),
        );
      }
    }

    // Mise à jour de l'état avec les nouveaux partages et augmentation du score valide
    final updatedRecords = [...newRecords, ...state.records];
    final newTotalUnique = state.totalUniqueShares + addedValidCount;

    state = state.copyWith(
      records: updatedRecords,
      totalUniqueShares: newTotalUnique,
      recipients: const [], // Réinitialise les destinataires en cours
    );

    return {
      'success': true,
      'addedCount': addedValidCount,
      'duplicateCount': duplicateCount,
    };
  }
}

final referralProvider =
    StateNotifierProvider<ReferralNotifier, ReferralState>(
  (ref) => ReferralNotifier(),
);
