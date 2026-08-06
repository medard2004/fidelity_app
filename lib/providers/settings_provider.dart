import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Langues prises en charge par l'app.
const List<Locale> supportedLocales = [Locale('fr'), Locale('en')];

/// Petite persistance locale pour les préférences (thème, langue) — un
/// fichier JSON plutôt qu'un plugin dédié (shared_preferences), pour ne
/// pas ajouter de dépendance native supplémentaire à l'app.
class _SettingsStore {
  static const _fileName = 'settings.json';
  static File? _cachedFile;

  static Future<File> _file() async {
    if (_cachedFile != null) return _cachedFile!;
    final dir = await getApplicationDocumentsDirectory();
    _cachedFile = File('${dir.path}/$_fileName');
    return _cachedFile!;
  }

  static Future<Map<String, dynamic>> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return {};
      final content = await file.readAsString();
      if (content.trim().isEmpty) return {};
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> write(String key, String value) async {
    try {
      final file = await _file();
      final current = await read();
      current[key] = value;
      await file.writeAsString(jsonEncode(current));
    } catch (_) {
      // Persistance best-effort : une écriture échouée ne doit jamais
      // bloquer le changement de préférence en mémoire.
    }
  }
}

const _themeModeKey = 'themeMode';
const _localeKey = 'locale';

// ─────────────────────────────────────────────────────────────────────────────
// Thème clair / sombre / système
// ─────────────────────────────────────────────────────────────────────────────

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _SettingsStore.read();
    state = switch (prefs[_themeModeKey]) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _SettingsStore.write(_themeModeKey, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Langue de l'application
// ─────────────────────────────────────────────────────────────────────────────

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _SettingsStore.read();
    final saved = prefs[_localeKey] as String?;
    if (saved != null && supportedLocales.any((l) => l.languageCode == saved)) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _SettingsStore.write(_localeKey, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
