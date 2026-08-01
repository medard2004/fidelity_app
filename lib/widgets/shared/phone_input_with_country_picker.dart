import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Modèle représentatif d'un pays avec son nom, indicatif et drapeau.
class CountryInfo {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryInfo({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

const List<CountryInfo> kCountries = [
  CountryInfo(name: 'Togo', code: 'TG', dialCode: '+228', flag: '🇹🇬'),
  CountryInfo(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
  CountryInfo(
      name: 'Côte d\'Ivoire', code: 'CI', dialCode: '+225', flag: '🇨🇮'),
  CountryInfo(name: 'Sénégal', code: 'SN', dialCode: '+221', flag: '🇸🇳'),
  CountryInfo(name: 'Bénin', code: 'BJ', dialCode: '+229', flag: '🇧🇯'),
  CountryInfo(name: 'Cameroun', code: 'CM', dialCode: '+237', flag: '🇨🇲'),
  CountryInfo(name: 'Mali', code: 'ML', dialCode: '+223', flag: '🇲🇱'),
  CountryInfo(name: 'Burkina Faso', code: 'BF', dialCode: '+226', flag: '🇧🇫'),
  CountryInfo(name: 'Gabon', code: 'GA', dialCode: '+241', flag: '🇬🇦'),
  CountryInfo(name: 'Congo', code: 'CG', dialCode: '+242', flag: '🇨🇬'),
  CountryInfo(name: 'RDC', code: 'CD', dialCode: '+243', flag: '🇨🇩'),
  CountryInfo(name: 'Niger', code: 'NE', dialCode: '+227', flag: '🇳🇪'),
  CountryInfo(name: 'Guinée', code: 'GN', dialCode: '+224', flag: '🇬🇳'),
  CountryInfo(name: 'Ghana', code: 'GH', dialCode: '+233', flag: '🇬🇭'),
  CountryInfo(name: 'Nigeria', code: 'NG', dialCode: '+234', flag: '🇳🇬'),
  CountryInfo(name: 'Maroc', code: 'MA', dialCode: '+212', flag: '🇲🇦'),
  CountryInfo(name: 'Algérie', code: 'DZ', dialCode: '+213', flag: '🇩ℤ'),
  CountryInfo(name: 'Tunisie', code: 'TN', dialCode: '+216', flag: '🇹🇳'),
  CountryInfo(name: 'États-Unis', code: 'US', dialCode: '+1', flag: '🇺🇸'),
  CountryInfo(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
  CountryInfo(name: 'Royaume-Uni', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
  CountryInfo(name: 'Belgique', code: 'BE', dialCode: '+32', flag: '🇧🇪'),
  CountryInfo(name: 'Suisse', code: 'CH', dialCode: '+41', flag: '🇨🇭'),
  CountryInfo(name: 'Allemagne', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
];

/// Champ de saisie du numéro de téléphone avec sélecteur d'indicateur pays.
class PhoneInputWithCountryPicker extends StatefulWidget {
  final TextEditingController controller;
  final String? initialCountryCode;
  final ValueChanged<CountryInfo>? onCountryChanged;
  final String? Function(String?)? validator;
  final String hintText;

  const PhoneInputWithCountryPicker({
    super.key,
    required this.controller,
    this.initialCountryCode = '+228',
    this.onCountryChanged,
    this.validator,
    this.hintText = '90 12 34 56',
  });

  @override
  State<PhoneInputWithCountryPicker> createState() =>
      PhoneInputWithCountryPickerState();
}

class PhoneInputWithCountryPickerState
    extends State<PhoneInputWithCountryPicker> {
  late CountryInfo selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = kCountries.firstWhere(
      (c) => c.dialCode == widget.initialCountryCode,
      orElse: () => kCountries.first,
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.porcelaine,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _CountryPickerModal(
          selectedCountry: selectedCountry,
          onSelect: (country) {
            setState(() => selectedCountry = country);
            widget.onCountryChanged?.call(country);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  /// Retourne le numéro de téléphone complet avec l'indicatif.
  String get fullPhoneNumber {
    final raw = widget.controller.text.trim();
    if (raw.isEmpty) return '';
    return '${selectedCountry.dialCode} $raw';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      style: AppTextStyles.bodyMedium(),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.bodyMedium(
          color: AppColors.encre.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: AppColors.saugePale.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        prefixIcon: GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            padding: const EdgeInsets.only(left: 12, right: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: AppColors.laitonLisere(opacity: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry.flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 4),
                Text(
                  selectedCountry.dialCode,
                  style: AppTextStyles.label().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: AppColors.laitonBrosse,
                ),
              ],
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.laitonBrosse,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
    );
  }
}

class _CountryPickerModal extends StatefulWidget {
  final CountryInfo selectedCountry;
  final ValueChanged<CountryInfo> onSelect;

  const _CountryPickerModal({
    required this.selectedCountry,
    required this.onSelect,
  });

  @override
  State<_CountryPickerModal> createState() => _CountryPickerModalState();
}

class _CountryPickerModalState extends State<_CountryPickerModal> {
  late List<CountryInfo> _filteredCountries;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = kCountries;
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredCountries = kCountries.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.dialCode.contains(q) ||
            c.code.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Poignée de glissement
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.encre.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(
                'Sélectionnez un indicatif',
                style: AppTextStyles.label().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 12),

              // Barre de recherche
              TextField(
                controller: _searchController,
                onChanged: _filter,
                style: AppTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  hintText: 'Rechercher un pays ou un indicatif...',
                  hintStyle: AppTextStyles.bodySmall(
                    color: AppColors.encre.withValues(alpha: 0.4),
                  ),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  filled: true,
                  fillColor: AppColors.saugePale.withValues(alpha: 0.4),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _filteredCountries.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.encre.withValues(alpha: 0.08),
                  ),
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    final isSelected =
                        country.code == widget.selectedCountry.code;

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        country.name,
                        style: AppTextStyles.bodyMedium(
                          color: isSelected
                              ? AppColors.vertBouteille
                              : AppColors.encre,
                        ).copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: Text(
                        country.dialCode,
                        style: AppTextStyles.monoMedium(
                          color: isSelected
                              ? AppColors.vertBouteille
                              : AppColors.encre.withValues(alpha: 0.6),
                        ),
                      ),
                      onTap: () => widget.onSelect(country),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
