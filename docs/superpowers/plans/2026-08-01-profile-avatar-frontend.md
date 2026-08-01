# Profile Avatar Upload (Frontend) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the user change or remove their profile photo from `profile_screen.dart`, using the backend endpoints built in the companion backend plan (`restaurant-loyalty-api`).

**Architecture:** A bottom sheet (styled like the existing country picker) offers camera / gallery / remove. Picked images go through a forced 1:1 crop (`image_cropper`) before upload. A new `UserAvatar` widget centralizes the initials-vs-photo rendering so `profile_screen.dart` is the only call site today but any future screen can reuse it. The existing service → repository → notifier layering (`AuthService` → `AuthRepository` → `AuthNotifier`) gets two new methods each, following the exact pattern already used by `updateProfile`.

**Tech Stack:** Flutter, Riverpod (`StateNotifier`), `dio` (multipart upload), `image_picker: ^1.2.3`, `image_cropper: ^12.2.1`.

**Spec:** `docs/superpowers/specs/2026-08-01-profile-avatar-design.md`

**Depends on:** the backend plan (`restaurant-loyalty-api/docs/superpowers/plans/2026-08-01-profile-avatar-backend.md`) must be deployed/running for end-to-end manual verification (Task 5) — Tasks 1-4 compile and analyze independently of it.

## Global Constraints

- Crop is always forced to 1:1 and always re-encoded to JPEG (`ImageCompressFormat.jpg`) client-side before upload — this means the upload is always `avatar.jpg` regardless of the original photo's format, so no MIME/extension detection is needed anywhere in the Flutter code.
- No optimistic avatar swap: the old photo (or initials) stays visible with a small spinner overlay until the server confirms; only a successful response updates `AuthState.user`.
- Upload field name is `avatar` (multipart), matching `UpdateAvatarRequest` on the backend.
- Response shape from both endpoints: `{ message: string, client: {...} }` — `AppUser.fromJson(response['client'])` already handles this (same helper `updateProfile` uses).
- This repo has no existing precedent for mocked HTTP/unit tests (`AuthService`/`AuthRepository`/`AuthNotifier` have zero test coverage today) — Task 2's correctness check is `flutter analyze`, not new test infrastructure invented for this feature alone. The one new widget (`UserAvatar`, Task 3) gets a real `flutter_test` widget test since that's genuinely testable without mocking network calls.

---

### Task 1: Dependencies & native permissions

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`

**Interfaces:**
- Produces: `image_picker` and `image_cropper` available for import in later tasks; camera permission granted on Android; camera/photo-library usage strings present on iOS (required by Apple, app is rejected at review without them).

- [ ] **Step 1: Add the two dependencies**

In `pubspec.yaml`, add after the `country_flags` line:

```yaml
  country_flags: ^1.1.1
  image_picker: ^1.2.3
  image_cropper: ^12.2.1
```

- [ ] **Step 2: Fetch packages**

Run: `flutter pub get`
Expected: succeeds, `pubspec.lock` updated with `image_picker`, `image_cropper` and their transitive platform packages.

- [ ] **Step 3: Add Android camera permission**

In `android/app/src/main/AndroidManifest.xml`, add the permission as the first child of `<manifest>`, before `<application>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CAMERA"/>
    <application
```

(Gallery access needs no manifest permission — `image_picker` uses Android's system Photo Picker on modern Android, which requires none.)

- [ ] **Step 4: Add iOS usage-description strings**

In `ios/Runner/Info.plist`, add these two keys right before the closing `</dict>` of the root plist:

```xml
	<key>NSCameraUsageDescription</key>
	<string>Carte a besoin d'accéder à l'appareil photo pour changer votre photo de profil.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Carte a besoin d'accéder à vos photos pour changer votre photo de profil.</string>
</dict>
```

- [ ] **Step 5: Verify**

Run: `flutter analyze`
Expected: no new errors (pre-existing warnings in unrelated files are fine, do not fix them here).

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist
git commit -m "chore: add image_picker and image_cropper for avatar upload"
```

---

### Task 2: API layer — service, repository, notifier, error handling

**Files:**
- Modify: `lib/api/services/auth_service.dart` (add `uploadAvatar`, `deleteAvatar`)
- Modify: `lib/api/repositories/auth_repository.dart` (add `uploadAvatar`, `deleteAvatar`)
- Modify: `lib/providers/app_providers.dart` (add `AuthNotifier.updateAvatar`, `AuthNotifier.removeAvatar`)
- Modify: `lib/core/errors/app_error.dart` (add `ErrorContext.updateAvatar`)
- Modify: `lib/core/errors/error_translator.dart` (handle the new context)
- Modify: `lib/core/errors/error_messages.dart` (add avatar-specific messages)

**Interfaces:**
- Consumes: `AppUser.fromJson(Map<String, dynamic>)` (existing, `lib/models/user.dart`), `ApiClient.dio` (existing, `lib/api/core/api_client.dart`), `AuthState.copyWith({AppUser? user})` (existing, `lib/providers/app_providers.dart`)
- Produces: `AuthNotifier.updateAvatar(File file): Future<void>` and `AuthNotifier.removeAvatar(): Future<void>` — Task 4 calls these exactly. `ErrorContext.updateAvatar` — Task 4's `handleError` call uses this exact enum value.

- [ ] **Step 1: Add the two calls to `AuthService`**

In `lib/api/services/auth_service.dart`, add `import 'dart:io';` at the top alongside the existing imports, then add these two methods right after `updateProfile` (after line 168):

```dart
  Future<Map<String, dynamic>> uploadAvatar(File file) => _guard(() async {
        final formData = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(file.path, filename: 'avatar.jpg'),
        });
        final response =
            await _apiClient.dio.post('/auth/profile/avatar', data: formData);
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> deleteAvatar() => _guard(() async {
        final response = await _apiClient.dio.delete('/auth/profile/avatar');
        return response.data as Map<String, dynamic>;
      });
```

- [ ] **Step 2: Add the two calls to `AuthRepository`**

In `lib/api/repositories/auth_repository.dart`, add `import 'dart:io';` at the top, then add after `updateProfile` (after line 94):

```dart
  Future<AppUser> uploadAvatar(File file) async {
    final response = await _authService.uploadAvatar(file);
    return AppUser.fromJson(response['client'] ?? {});
  }

  Future<AppUser> deleteAvatar() async {
    final response = await _authService.deleteAvatar();
    return AppUser.fromJson(response['client'] ?? {});
  }
```

- [ ] **Step 3: Add the two notifier methods**

In `lib/providers/app_providers.dart`, add after `updateFullProfile` (after line 471, before `signOut`):

```dart
  /// Pas de mise à jour optimiste ici : contrairement à [updateFullProfile],
  /// rien n'est affiché avant la confirmation serveur (voir spec avatar).
  Future<void> updateAvatar(File file) async {
    if (state.user == null) return;
    final updatedUser = await _authRepository.uploadAvatar(file);
    state = state.copyWith(user: updatedUser);
  }

  Future<void> removeAvatar() async {
    if (state.user == null) return;
    final updatedUser = await _authRepository.deleteAvatar();
    state = state.copyWith(user: updatedUser);
  }
```

Add `import 'dart:io';` at the top of this file if not already present.

- [ ] **Step 4: Add the error context**

In `lib/core/errors/app_error.dart`, add `updateAvatar,` to the `ErrorContext` enum (after `updateProfile,` at line 44):

```dart
enum ErrorContext {
  login,
  socialLogin,
  signup,
  forgotPassword,
  verifyOtp,
  resetPassword,
  completeProfile,
  updateProfile,
  updateAvatar,
  verifyPassword,
  changePassword,
}
```

- [ ] **Step 5: Add avatar messages to the catalog**

In `lib/core/errors/error_messages.dart`, add after `profileCompleteFailed` (after line 82):

```dart
  static const avatarUpdateFailed =
      "Impossible de mettre à jour la photo de profil. Réessayez.";
  static const avatarUpdateSuccess = "Photo de profil mise à jour.";
  static const avatarRemoveSuccess = "Photo de profil supprimée.";
  static const avatarInvalid =
      "Cette image ne peut pas être utilisée. Essayez-en une autre.";
```

- [ ] **Step 6: Wire the new context into `ErrorTranslator`**

In `lib/core/errors/error_translator.dart`:

a) In `_fallbackMessage` (the switch has no `default`, so this is required for the code to compile), add before the closing brace of the switch (after line 255):

```dart
      case ErrorContext.updateProfile:
        return ErrorMessages.profileSaveFailed;
      case ErrorContext.updateAvatar:
        return ErrorMessages.avatarUpdateFailed;
      case ErrorContext.verifyPassword:
```

b) In `_invalidMessage(String field)` (line 130-154), add a case for the `avatar` field so a 422 on that field shows a specific message instead of the generic fallback:

```dart
      case 'birthdate':
        return ErrorMessages.birthdateInvalid;
      case 'avatar':
        return ErrorMessages.avatarInvalid;
      case 'referral_code':
```

- [ ] **Step 7: Verify**

Run: `flutter analyze`
Expected: no errors on any of the 6 modified files (this task has no automated test — see Global Constraints for why — `flutter analyze` is the correctness gate here).

- [ ] **Step 8: Commit**

```bash
git add lib/api/services/auth_service.dart lib/api/repositories/auth_repository.dart lib/providers/app_providers.dart lib/core/errors/app_error.dart lib/core/errors/error_messages.dart lib/core/errors/error_translator.dart
git commit -m "feat: add avatar upload/delete API layer"
```

---

### Task 3: `UserAvatar` reusable widget

**Files:**
- Create: `lib/widgets/shared/user_avatar.dart`
- Test: `test/widgets/user_avatar_test.dart`

**Interfaces:**
- Consumes: `AppColors.vertBouteille`, `AppColors.laitonBrosse`, `AppColors.ombreChaude(opacity:)`, `AppColors.encre`, `AppColors.porcelaine` (all existing, `lib/core/theme/app_colors.dart`)
- Produces: `UserAvatar({required String fullName, String? photoUrl, double radius = 32, bool isLoading = false})` — Task 4 uses this exact constructor.

- [ ] **Step 1: Write the failing widget test**

Create `test/widgets/user_avatar_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/widgets/user_avatar_test.dart`
Expected: FAIL — `package:carte_app/widgets/shared/user_avatar.dart` doesn't exist yet.

- [ ] **Step 3: Implement the widget**

Create `lib/widgets/shared/user_avatar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Avatar de profil : affiche la photo si définie, sinon les initiales.
/// Point d'entrée unique pour ce rendu — évite de dupliquer la logique si
/// l'avatar doit apparaître ailleurs que `profile_screen.dart` plus tard.
class UserAvatar extends StatelessWidget {
  final String fullName;
  final String? photoUrl;
  final double radius;
  final bool isLoading;

  const UserAvatar({
    super.key,
    required this.fullName,
    this.photoUrl,
    this.radius = 32,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.vertBouteille,
            border: Border.all(color: AppColors.laitonBrosse, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.ombreChaude(opacity: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: (photoUrl != null && photoUrl!.isNotEmpty)
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    errorBuilder: (context, error, stackTrace) => _initials(),
                  )
                : _initials(),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.encre.withValues(alpha: 0.35),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.porcelaine,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
        style: GoogleFonts.bodoniModa(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
          color: AppColors.porcelaine,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/widgets/user_avatar_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/shared/user_avatar.dart test/widgets/user_avatar_test.dart
git commit -m "feat: add reusable UserAvatar widget"
```

---

### Task 4: Wire the avatar flow into `profile_screen.dart`

**Files:**
- Modify: `lib/features/profile/profile_screen.dart`

**Interfaces:**
- Consumes: `UserAvatar` (Task 3), `AuthNotifier.updateAvatar`/`removeAvatar` (Task 2), `ErrorContext.updateAvatar` (Task 2), `ErrorMessages.avatarUpdateSuccess`/`avatarRemoveSuccess` (Task 2), `FormErrorHandler` mixin (existing, `lib/core/errors/form_error_handler.dart`)

- [ ] **Step 1: Convert `ProfileScreen` to a `ConsumerStatefulWidget`**

Change the class declaration (lines 14-15) from:

```dart
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
```

to:

```dart
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with FormErrorHandler {
```

Change the `build` method signature (line 77-78) from:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
```

to:

```dart
  @override
  Widget build(BuildContext context) {
```

(`ref` is now available as an inherited field from `ConsumerState` — every existing `ref.watch(...)` call in the method body keeps working unchanged. Leave `_confirmSignOut(BuildContext context, WidgetRef ref)` and its call site untouched — it already takes both as parameters, so it doesn't care whether it's called from a widget or a state class. Don't forget the closing `}` of the file now closes one extra class — check it still balances.)

- [ ] **Step 2: Add the new imports**

At the top of the file, add after the existing imports (after line 12):

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../models/user.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/errors/form_error_handler.dart';
import '../../widgets/shared/user_avatar.dart';
```

- [ ] **Step 3: Add the avatar action methods**

Add these three methods right after `_confirmSignOut` (after line 75, before `build`):

```dart
  Future<void> _showAvatarOptions(AppUser user) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.porcelaine,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.encre.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.encre),
              title: Text('Prendre une photo', style: AppTextStyles.bodyMedium()),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.encre),
              title: Text('Choisir dans la galerie', style: AppTextStyles.bodyMedium()),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.bordeauxProfond),
                title: Text(
                  'Supprimer la photo',
                  style: AppTextStyles.bodyMedium(color: AppColors.bordeauxProfond),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _removeAvatar();
                },
              ),
            ListTile(
              title: Center(
                child: Text(
                  'Annuler',
                  style: AppTextStyles.bodyMedium(color: AppColors.encre.withValues(alpha: 0.5)),
                ),
              ),
              onTap: () => Navigator.pop(sheetContext),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final XFile? picked = await ImagePicker().pickImage(source: source, imageQuality: 90);
    if (picked == null || !mounted) return;

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 1024,
      maxHeight: 1024,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer la photo',
          toolbarColor: AppColors.porcelaine,
          toolbarWidgetColor: AppColors.encre,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        const IOSUiSettings(
          title: 'Recadrer la photo',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null || !mounted) return;

    try {
      await runGuarded(
        () => ref.read(authProvider.notifier).updateAvatar(File(cropped.path)),
      );
      if (mounted) showSuccessToast(ErrorMessages.avatarUpdateSuccess);
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.updateAvatar);
    }
  }

  Future<void> _removeAvatar() async {
    try {
      await runGuarded(() => ref.read(authProvider.notifier).removeAvatar());
      if (mounted) showSuccessToast(ErrorMessages.avatarRemoveSuccess);
    } catch (e) {
      if (mounted) handleError(e, context: ErrorContext.updateAvatar);
    }
  }
```

- [ ] **Step 4: Replace the inline avatar circle with `UserAvatar`**

Replace the `Container` block that renders the initials circle (lines 186-216) — the one with `width: 64, height: 64` and the `Center(child: Text(user.fullName...))` — with:

```dart
                          GestureDetector(
                            onTap: isBusy ? null : () => _showAvatarOptions(user),
                            child: UserAvatar(
                              fullName: user.fullName,
                              photoUrl: user.photoUrl,
                              radius: 32,
                              isLoading: isBusy,
                            ),
                          ),
```

This sits nested inside the outer `GestureDetector` that navigates to `/personal-info` on tap — tapping directly on the avatar circle triggers only this inner handler (opens the photo sheet), tapping anywhere else on the card still navigates to `/personal-info`, since Flutter dispatches the tap to the innermost `GestureDetector` that claims it.

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/features/profile/profile_screen.dart`
Expected: no errors.

Run: `flutter test`
Expected: all tests pass, including the `UserAvatar` tests from Task 3 (this screen has no widget test of its own — none existed before this change either).

- [ ] **Step 6: Commit**

```bash
git add lib/features/profile/profile_screen.dart
git commit -m "feat: wire avatar upload/remove flow into profile screen"
```

---

### Task 5: Manual end-to-end verification

Requires the backend plan (`restaurant-loyalty-api`) deployed and reachable from the device/emulator running this app, and `php artisan storage:link` already run on that backend.

- [ ] Launch the app via the `run` skill (or `flutter run`) on an emulator/device with both a front camera and a photo library with at least one image.
- [ ] Open Profil → tap the avatar circle → bottom sheet appears with "Prendre une photo", "Choisir dans la galerie", "Annuler" (no "Supprimer la photo" yet, since no avatar is set).
- [ ] Tap "Choisir dans la galerie" → pick an image → crop screen opens locked to a square → confirm crop → spinner appears briefly on the avatar circle → avatar updates to the cropped photo, success toast shown.
- [ ] Re-open the sheet → "Supprimer la photo" is now visible → tap it → confirm the avatar reverts to initials, success toast shown, and "Supprimer la photo" disappears from the sheet again.
- [ ] Tap "Prendre une photo" → take a picture with the camera → crop → confirm it uploads and displays correctly.
- [ ] Turn off the backend (or airplane mode) and repeat an upload → confirm a red toast error appears (not a silent failure) and the avatar stays unchanged.
- [ ] Force-quit and reopen the app → confirm the previously uploaded avatar still displays (persisted server-side, reloaded via `/auth/me` on app start).
- [ ] On Android, deny the camera permission when prompted → confirm the app doesn't crash and shows a reasonable error rather than hanging.
