import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Widget premium pour la saisie d'un code OTP à 6 chiffres.
///
/// Caractéristiques :
/// - Curseur clignotant animé sur la case active
/// - Transitions fluides entre états (vide, actif, rempli)
/// - Support du copier-coller (paste) automatique
/// - Design « Porcelaine » cohérent avec le design system
class OtpInputRow extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  const OtpInputRow({super.key, required this.onCompleted});

  @override
  State<OtpInputRow> createState() => OtpInputRowState();
}

class OtpInputRowState extends State<OtpInputRow>
    with SingleTickerProviderStateMixin {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _activeIndex = 0;
  bool _hasFocus = false;

  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;

  @override
  void initState() {
    super.initState();

    // Curseur clignotant
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _cursorAnimation = CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    );

    // Écouter le focus global
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    final anyFocused = _focusNodes.any((f) => f.hasFocus);
    if (mounted && anyFocused != _hasFocus) {
      setState(() => _hasFocus = anyFocused);
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.removeListener(_onFocusChange);
      f.dispose();
    }
    super.dispose();
  }

  void _setActiveIndex(int index) {
    if (!mounted) return;
    setState(() => _activeIndex = index);
  }

  /// Efface tout le contenu et redonne le focus à la première case
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _setActiveIndex(0);
    _focusNodes.first.requestFocus();
  }

  void _onChanged(int index, String value) {
    // Gestion du copier-coller (plusieurs chiffres)
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < digits.length && index + i < 6; i++) {
        _controllers[index + i].text = digits[i];
        _controllers[index + i].selection = TextSelection.fromPosition(
          TextPosition(offset: _controllers[index + i].text.length),
        );
      }

      final nextIndex = (index + digits.length).clamp(0, 5);
      _focusNodes[nextIndex].requestFocus();
      _setActiveIndex(nextIndex);

      final pastedCode = _controllers.map((c) => c.text).join();
      if (pastedCode.length == 6) widget.onCompleted(pastedCode);
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
        _setActiveIndex(index + 1);
      } else {
        _focusNodes[index].unfocus();
        _setActiveIndex(index);
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
      _setActiveIndex(index - 1);
    } else {
      _setActiveIndex(index);
    }

    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) widget.onCompleted(code);
  }

  // Espace entre deux cases voisines, et espace (plus large) entre les deux
  // groupes de 3 — cet écart supplémentaire à lui seul suffit à grouper
  // visuellement 3+3 chiffres, sans élément décoratif séparé à faire entrer
  // dans le calcul de largeur.
  static const double _gap = 8;
  static const double _midGap = 20;
  static const double _minCellSize = 40;
  static const double _maxCellSize = 56;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const totalGaps = _gap * 4 + _midGap;
        final rawSize = (constraints.maxWidth - totalGaps) / 6;
        final cellSize = rawSize.clamp(_minCellSize, _maxCellSize);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final isActive = i == _activeIndex && _hasFocus;
            final isFilled = _controllers[i].text.isNotEmpty;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0) SizedBox(width: i == 3 ? _midGap : _gap),
                _buildCell(i, isActive, isFilled, cellSize),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildCell(int index, bool isActive, bool isFilled, double cellSize) {
    return AnimatedContainer(
      width: cellSize,
      height: cellSize * 1.24,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.porcelaine
            : isFilled
                ? AppColors.saugePale.withValues(alpha: 0.5)
                : AppColors.saugePale.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.laitonBrosse
              : isFilled
                  ? AppColors.laitonBrosse.withValues(alpha: 0.4)
                  : AppColors.laitonLisere(opacity: 0.25),
          width: isActive ? 2.0 : 1.2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.laitonBrosse.withValues(alpha: 0.12),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : isFilled
                ? [
                    BoxShadow(
                      color: AppColors.ombreChaude(opacity: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Chiffre centré ─────────────────────────────────────────
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controllers[index],
            builder: (_, value, __) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.easeOut,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  value.text,
                  key: ValueKey('otp_$index\_${value.text}'),
                  style: AppTextStyles.monoLarge(
                    color: AppColors.encre,
                  ).copyWith(
                    fontSize: cellSize * 0.46,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              );
            },
          ),

          // ── Curseur clignotant ─────────────────────────────────────
          if (isActive && !isFilled)
            Positioned(
              bottom: cellSize * 0.225,
              child: FadeTransition(
                opacity: _cursorAnimation,
                child: Container(
                  width: cellSize * 0.36,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: AppColors.laitonBrosse,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

          // ── TextField invisible pour capter la saisie ──────────────
          TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onTap: () => _setActiveIndex(index),
            onChanged: (v) => _onChanged(index, v),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            textInputAction:
                index == 5 ? TextInputAction.done : TextInputAction.next,
            maxLength: 1,
            cursorColor: Colors.transparent,
            cursorWidth: 0,
            showCursor: false,
            enableInteractiveSelection: true,
            selectionControls: MaterialTextSelectionControls(),
            style: TextStyle(color: Colors.transparent, fontSize: cellSize * 0.46),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
