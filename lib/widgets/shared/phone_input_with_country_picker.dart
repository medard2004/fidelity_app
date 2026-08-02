import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_flags/country_flags.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_countries.dart';

export '../../core/constants/app_countries.dart';

/// Ouvre le sélecteur de pays maison (drapeaux vectoriels, recherche, sections
/// Afrique / Reste du monde) — à réutiliser partout où un pays doit être choisi,
/// avec ou sans indicatif téléphonique.
Future<void> showAppCountryPicker({
  required BuildContext context,
  required ValueChanged<CountryInfo> onSelect,
  CountryInfo? selectedCountry,
  bool showDialCode = true,
  String title = 'Sélectionner un pays',
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.porcelaine,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _CountryPickerModal(
        selectedCountry: selectedCountry ?? kAfricanCountries.first,
        showDialCode: showDialCode,
        title: title,
        onSelect: (country) {
          onSelect(country);
          Navigator.pop(context);
        },
      );
    },
  );
}

/// Champ de saisie du numéro de téléphone avec sélecteur d'indicateur pays.
class PhoneInputWithCountryPicker extends StatefulWidget {
  final TextEditingController controller;
  final String? initialCountryCode;
  final ValueChanged<CountryInfo>? onCountryChanged;
  final String? Function(String?)? validator;
  final String hintText;
  final ValueChanged<String>? onFieldSubmitted;

  const PhoneInputWithCountryPicker({
    super.key,
    required this.controller,
    this.initialCountryCode = '+228',
    this.onCountryChanged,
    this.validator,
    this.hintText = '90 12 34 56',
    this.onFieldSubmitted,
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
    selectedCountry = kAllCountries.firstWhere(
      (c) => c.dialCode == widget.initialCountryCode,
      orElse: () => kAfricanCountries.firstWhere((c) => c.dialCode == '+228',
          orElse: () => kAfricanCountries.first),
    );
  }

  void _showCountryPicker() {
    showAppCountryPicker(
      context: context,
      selectedCountry: selectedCountry,
      onSelect: (country) {
        setState(() => selectedCountry = country);
        widget.onCountryChanged?.call(country);
      },
    );
  }

  /// Retourne le numéro de téléphone complet avec l'indicatif sans espaces.
  String get fullPhoneNumber {
    final raw = widget.controller.text.trim();
    if (raw.isEmpty) return '';
    
    // Ne garder que les chiffres pour le nettoyage final
    String sanitized = raw.replaceAll(RegExp(r'\D'), '');
    
    // Si l'utilisateur a tapé explicitement le + suivi de chiffres (ex: dans un copier-coller)
    if (raw.startsWith('+')) {
      return '+$sanitized';
    }
    
    // Si l'utilisateur a tapé l'indicatif sans le +, on l'ignore pour éviter les doublons
    final dialCodeNoPlus = selectedCountry.dialCode.replaceAll('+', '');
    if (sanitized.startsWith(dialCodeNoPlus) && sanitized.length >= dialCodeNoPlus.length + 7) {
      sanitized = sanitized.substring(dialCodeNoPlus.length);
    }
    
    return '${selectedCountry.dialCode}$sanitized';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Seulement des chiffres
        LengthLimitingTextInputFormatter(15),   // Longueur max raisonnable internationale
      ],
      style: AppTextStyles.bodyMedium().copyWith(letterSpacing: 1.2),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.bodyMedium(
          color: AppColors.encre.withValues(alpha: 0.35),
        ).copyWith(letterSpacing: 1.2),
        filled: true,
        fillColor: AppColors.saugePale.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        prefixIcon: GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            padding: const EdgeInsets.only(left: 14, right: 10),
            margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
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
                CountryFlags.flag(
                  selectedCountry.code,
                  width: 24,
                  height: 18,
                  borderRadius: 3,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedCountry.dialCode,
                  style: AppTextStyles.label().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 16,
                  color: AppColors.encre.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.laitonLisere(opacity: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.laitonBrosse,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bordeauxProfond, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bordeauxProfond, width: 1.5),
        ),
      ),
    );
  }
}

class _CountryPickerModal extends StatefulWidget {
  final CountryInfo selectedCountry;
  final ValueChanged<CountryInfo> onSelect;
  final bool showDialCode;
  final String title;

  const _CountryPickerModal({
    required this.selectedCountry,
    required this.onSelect,
    this.showDialCode = true,
    this.title = 'Indicatif pays',
  });

  @override
  State<_CountryPickerModal> createState() => _CountryPickerModalState();
}

class _CountryPickerModalState extends State<_CountryPickerModal> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
  }

  List<CountryInfo> _getFiltered(List<CountryInfo> source) {
    if (_searchQuery.isEmpty) return source;
    return source.where((c) {
      return c.name.toLowerCase().contains(_searchQuery) ||
          c.dialCode.contains(_searchQuery) ||
          c.code.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAfrican = _getFiltered(kAfricanCountries);
    final filteredOther = _getFiltered(kOtherCountries);
    
    // Calcul pour savoir si on affiche les en-têtes
    final hasAfrican = filteredAfrican.isNotEmpty;
    final hasOther = filteredOther.isNotEmpty;
    final isSearching = _searchQuery.isNotEmpty;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.porcelaine,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Poignée de glissement ───────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.encre.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),

              // ── Titre ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.displayMedium().copyWith(
                        fontSize: 20,
                        color: AppColors.encre,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.encre.withValues(alpha: 0.05),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.encre.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Barre de recherche Premium ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.porcelaine,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _searchFocusNode.hasFocus 
                          ? AppColors.laitonBrosse
                          : AppColors.laitonLisere(opacity: 0.3),
                      width: _searchFocusNode.hasFocus ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      if (_searchFocusNode.hasFocus)
                        BoxShadow(
                          color: AppColors.laitonBrosse.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      else
                        BoxShadow(
                          color: AppColors.ombreChaude(opacity: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _filter,
                    style: AppTextStyles.bodyMedium(),
                    decoration: InputDecoration(
                      hintText: widget.showDialCode
                          ? 'Rechercher un pays (ex: Mali, +223)...'
                          : 'Rechercher un pays...',
                      hintStyle: AppTextStyles.bodyMedium(
                        color: AppColors.encre.withValues(alpha: 0.35),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _searchFocusNode.hasFocus
                            ? AppColors.laitonBrosse
                            : AppColors.encre.withValues(alpha: 0.3),
                        size: 22,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel_rounded,
                                color: AppColors.encre.withValues(alpha: 0.3),
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filter('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              Divider(height: 1, color: AppColors.encre.withValues(alpha: 0.06)),

              // ── Liste des pays ─────────────────────────────────────────
              Expanded(
                child: (!hasAfrican && !hasOther)
                    ? _buildEmptyState()
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 32),
                        children: [
                          if (hasAfrican) ...[
                            if (!isSearching) _buildSectionHeader('PAYS D\'AFRIQUE', Icons.public),
                            ...filteredAfrican.map((c) => _buildCountryTile(c)),
                          ],
                          
                          if (hasAfrican && hasOther && !isSearching)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: AppColors.encre.withValues(alpha: 0.06)),
                            ),
                            
                          if (hasOther) ...[
                            if (!isSearching) _buildSectionHeader('RESTE DU MONDE', Icons.language_rounded),
                            ...filteredOther.map((c) => _buildCountryTile(c)),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.encre.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun pays trouvé',
            style: AppTextStyles.bodyMedium(
              color: AppColors.encre.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.laitonBrosse,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.monoSmall(
              color: AppColors.laitonBrosse,
            ).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryTile(CountryInfo country) {
    final isSelected = country.code == widget.selectedCountry.code;

    return InkWell(
      onTap: () => widget.onSelect(country),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: isSelected ? AppColors.vertBouteille.withValues(alpha: 0.06) : Colors.transparent,
        child: Row(
          children: [
            // Drapeau
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.porcelaine,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ombreChaude(opacity: 0.05),
                    blurRadius: 4,
                  )
                ],
              ),
              alignment: Alignment.center,
              child: ClipOval(
                child: CountryFlags.flag(
                  country.code,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Nom du pays
            Expanded(
              child: Text(
                country.name,
                style: AppTextStyles.bodyMedium(
                  color: isSelected ? AppColors.vertBouteille : AppColors.encre,
                ).copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
            
            // Indicatif
            if (widget.showDialCode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.vertBouteille.withValues(alpha: 0.1)
                      : AppColors.saugePale.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  country.dialCode,
                  style: AppTextStyles.monoMedium(
                    color: isSelected ? AppColors.vertBouteille : AppColors.encre.withValues(alpha: 0.7),
                  ).copyWith(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                ),
              ),

            if (isSelected) ...[
              const SizedBox(width: 12),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.vertBouteille,
                size: 20,
              ),
            ] else ...[
              const SizedBox(width: 32),
            ],
          ],
        ),
      ),
    );
  }
}
