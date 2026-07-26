import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OtpInputRow extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  const OtpInputRow({super.key, required this.onCompleted});

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _setActiveIndex(int index) {
    if (!mounted) return;
    setState(() => _activeIndex = index);
  }

  void _onChanged(int index, String value) {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final active = i == _activeIndex;
        return AnimatedContainer(
          width: 48,
          height: 60,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.porcelaine,
                      AppColors.saugePale.withAlpha(220),
                    ],
                  )
                : null,
            color: active
                ? AppColors.porcelaine
                : AppColors.saugePale.withAlpha(180),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? AppColors.laitonBrosse
                  : AppColors.laitonLisere(opacity: 0.36),
              width: active ? 1.7 : 1.05,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.ombreChaude(opacity: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Chiffre centré ─────────────────────────────────────────
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controllers[i],
                builder: (_, value, __) {
                  return Center(
                    child: Text(
                      value.text,
                      style: AppTextStyles.monoLarge(
                        color: AppColors.encre,
                      ).copyWith(
                        fontSize: 22,
                        height: 1,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  );
                },
              ),
              // ── TextField transparent qui capte la saisie ──────────────
              TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                onTap: () => _setActiveIndex(i),
                onChanged: (v) => _onChanged(i, v),
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                textInputAction:
                    i == 5 ? TextInputAction.done : TextInputAction.next,
                maxLength: 1,
                cursorColor: Colors.transparent,
                cursorWidth: 0,
                showCursor: false,
                enableInteractiveSelection: true,
                selectionControls: MaterialTextSelectionControls(),
                // Texte rendu invisible — on affiche le ValueListenableBuilder au-dessus.
                style: const TextStyle(color: Colors.transparent, fontSize: 22),
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
      }),
    );
  }
}
