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
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
        setState(() => _activeIndex = index + 1);
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
      setState(() => _activeIndex = index - 1);
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
        return SizedBox(
          width: 44,
          child: Column(
            children: [
              TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                onTap: () => setState(() => _activeIndex = i),
                onChanged: (v) => _onChanged(i, v),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: AppTextStyles.monoLarge(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                margin: const EdgeInsets.only(top: 4),
                color: active
                    ? AppColors.laitonBrosse
                    : AppColors.laitonLisere(opacity: 0.2),
              ),
            ],
          ),
        );
      }),
    );
  }
}
