import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/sanchora_button.dart';
import 'package:sanchora/features/profile/widgets/profile_avatar_picker.dart';
import 'package:sanchora/features/profile/widgets/profile_info_section.dart';
import 'package:sanchora/features/profile/utils/phone_input_formatter.dart';
import 'package:sanchora/core/widgets/sanchora_page_header.dart';
import 'package:sanchora/features/auth/screens/change_password_screen.dart';
import 'package:sanchora/features/auth/screens/connected_accounts_screen.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  // Original Data
  final String _origName = 'Hemanth Paruchuri';
  final String _origEmail = 'hemanth@example.com';
  final String _origPhone = '+91 98765 43210';
  final String _origDob = '15 Aug 1995';
  final String _origGender = 'Male';
  final String _origCountry = 'India';
  final String _origLanguage = 'English';
  final bool _origCommEmail = true;
  final bool _origMktEmail = false;
  final bool _origUpdates = true;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late final TextEditingController _genderController;
  late final TextEditingController _countryController;
  late final TextEditingController _languageController;

  late final FocusNode _nameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _phoneFocus;

  String? _nameError;
  String? _emailError;
  String? _phoneError;

  late bool _commEmail;
  late bool _mktEmail;
  late bool _updates;

  bool _hasChanges = false;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _origName);
    
    String initialPhone = _origPhone;
    if (_origCountry.contains('India') && initialPhone.length == 10 && RegExp(r'^\d+$').hasMatch(initialPhone)) {
      initialPhone = '+91 ${initialPhone.substring(0, 5)} ${initialPhone.substring(5)}';
    }
    _phoneController = TextEditingController(text: initialPhone);
    
    _emailController = TextEditingController(text: _origEmail);
    _dobController = TextEditingController(text: _origDob);
    _genderController = TextEditingController(text: _origGender);
    _countryController = TextEditingController(text: _origCountry);
    _languageController = TextEditingController(text: _origLanguage);

    _nameFocus = FocusNode()..addListener(() {
      if (!_nameFocus.hasFocus) _validateName();
    });
    _emailFocus = FocusNode()..addListener(() {
      if (!_emailFocus.hasFocus) _validateEmail();
    });
    _phoneFocus = FocusNode()..addListener(() {
      if (!_phoneFocus.hasFocus) _validatePhone();
    });

    _nameController.addListener(() {
      _checkChanges();
      if (_nameError != null) _validateName();
    });
    _emailController.addListener(() {
      _checkChanges();
      if (_emailError != null) _validateEmail();
    });
    _phoneController.addListener(() {
      _checkChanges();
      if (_phoneError != null) _validatePhone();
    });
    _dobController.addListener(_checkChanges);
    _genderController.addListener(_checkChanges);
    _countryController.addListener(_checkChanges);
    _languageController.addListener(_checkChanges);

    _commEmail = _origCommEmail;
    _mktEmail = _origMktEmail;
    _updates = _origUpdates;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final hasChanges = _nameController.text != _origName ||
        _emailController.text != _origEmail ||
        _phoneController.text != _origPhone ||
        _dobController.text != _origDob ||
        _genderController.text != _origGender ||
        _countryController.text != _origCountry ||
        _languageController.text != _origLanguage ||
        _commEmail != _origCommEmail ||
        _mktEmail != _origMktEmail ||
        _updates != _origUpdates;

    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
        _isValid = true;
      });
    }
  }

  bool _validateName() {
    final text = _nameController.text.trim();
    String? error;
    if (text.isEmpty) {
      error = 'Please enter your full name.';
    } else if (text.length < 2) {
      error = 'Name must contain at least 2 characters.';
    } else if (text.length > 50) {
      error = 'Name cannot exceed 50 characters.';
    } else if (RegExp(r'[0-9!@#\$%^&\*\(\)_\+=\{\}\[\]\|\\:;"<>,.?/~`]').hasMatch(text)) {
      error = 'Name contains invalid characters.';
    }
    
    if (_nameError != error) {
      setState(() => _nameError = error);
    }
    return error == null;
  }

  bool _validateEmail() {
    final text = _emailController.text.trim();
    String? error;
    if (text.isEmpty) {
      error = 'Please enter your email address.';
    } else {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(text)) {
        error = 'Please enter a valid email address.';
      }
    }
    
    if (_emailError != error) {
      setState(() => _emailError = error);
    }
    return error == null;
  }

  bool _validatePhone() {
    String text = _phoneController.text;
    String? error;
    
    if (_countryController.text.contains('India')) {
      if (text.startsWith('+91')) {
        text = text.substring(3);
      }
      text = text.replaceAll(RegExp(r'[\s\-]'), '');
      
      if (text.isEmpty) {
        error = 'Please enter your mobile number.';
      } else if (RegExp(r'\D').hasMatch(text)) {
        error = 'Please enter a valid mobile number.';
      } else if (text.length != 10) {
        error = 'Please enter a valid mobile number.';
      } else if (!RegExp(r'^[6-9]').hasMatch(text)) {
        error = 'Please enter a valid mobile number.';
      }
    } else {
      text = text.replaceAll(' ', '');
      if (text.isEmpty) {
        error = 'Please enter your mobile number.';
      } else if (text.contains(RegExp(r'[a-zA-Z]'))) {
        error = 'Please enter a valid mobile number.';
      } else if (text.replaceAll(RegExp(r'\D'), '').length < 10) {
        error = 'Please enter a valid mobile number.';
      }
    }
    
    if (_phoneError != error) {
      setState(() => _phoneError = error);
    }
    return error == null;
  }

  Future<void> _onSave() async {
    if (!_hasChanges) return;

    final isNameValid = _validateName();
    final isEmailValid = _validateEmail();
    final isPhoneValid = _validatePhone();

    if (!isNameValid || !isEmailValid || !isPhoneValid) {
      if (!isNameValid) {
        _nameFocus.requestFocus();
      } else if (!isEmailValid) {
        _emailFocus.requestFocus();
      } else if (!isPhoneValid) {
        _phoneFocus.requestFocus();
      }
      return;
    }

    // Process formatting on save
    _nameController.text = _nameController.text.trim();
    _emailController.text = _emailController.text.trim().toLowerCase();

    // Extract digits for backend storage
    String phoneForStorage = _phoneController.text;
    if (_countryController.text.contains('India')) {
      if (phoneForStorage.startsWith('+91')) {
        phoneForStorage = phoneForStorage.substring(3);
      }
      phoneForStorage = phoneForStorage.replaceAll(RegExp(r'\D'), '');
    }
    // TODO: Send phoneForStorage to backend instead of raw UI text

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Profile updated successfully',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Unsaved Changes',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to discard them?',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Continue Editing',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Discard Changes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF87171),
                ),
              ),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  String? get _dobAgeText {
    if (_dobController.text.isEmpty) return null;
    try {
      final parts = _dobController.text.split(' ');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months.indexOf(parts[1]) + 1;
      final year = int.parse(parts[2]);
      
      final dob = DateTime(year, month, day);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return '$age years old';
    } catch (e) {
      return null;
    }
  }

  Future<void> _showDobPicker() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Default to 13 years ago if empty
    DateTime selectedDate = DateTime.now().subtract(const Duration(days: 365 * 13));
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        final formatted = '${selectedDate.day.toString().padLeft(2, '0')} ${months[selectedDate.month - 1]} ${selectedDate.year}';
                        setState(() {
                          _dobController.text = formatted;
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Done', style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    maximumDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showOptionSelector(String title, List<String> options, TextEditingController controller) async {
    final theme = Theme.of(context);
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ...options.map((option) {
                final isSelected = controller.text == option;
                return InkWell(
                  onTap: () {
                    setState(() {
                      controller.text = option;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: isSelected 
                              ? const Icon(Icons.circle, color: Colors.white, size: 8) 
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showGenderPicker() => _showOptionSelector('Gender', ['Male', 'Female', 'Prefer not to say'], _genderController);

  Future<void> _showLanguagePicker() => _showOptionSelector('Language', ['English', 'Telugu', 'Hindi', 'Tamil', 'Kannada', 'Malayalam'], _languageController);

  Future<void> _showCountrySelector() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final List<Map<String, String>> allCountries = [
      {'name': 'Australia', 'flag': '🇦🇺'},
      {'name': 'Canada', 'flag': '🇨🇦'},
      {'name': 'France', 'flag': '🇫🇷'},
      {'name': 'Germany', 'flag': '🇩🇪'},
      {'name': 'India', 'flag': '🇮🇳'},
      {'name': 'United Kingdom', 'flag': '🇬🇧'},
      {'name': 'United States', 'flag': '🇺🇸'},
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String searchQuery = '';
        final TextEditingController searchController = TextEditingController();
        
        Widget buildCountryRow(Map<String, String> country) {
          final isSelected = _countryController.text.contains(country['name']!);
          return InkWell(
            onTap: () {
              setState(() {
                _countryController.text = '${country['flag']}  ${country['name']}';
              });
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
              child: Row(
                children: [
                  Text(country['flag']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      country['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 20),
                ],
              ),
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = allCountries.where((c) => c['name']!.toLowerCase().contains(searchQuery.toLowerCase())).toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      'Select Country',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.cancel_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                                  onPressed: () {
                                    setModalState(() {
                                      searchQuery = '';
                                      searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (searchQuery.isEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 24, top: 8, bottom: 4),
                            child: Text(
                              'Current',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                            ),
                          ),
                          buildCountryRow(allCountries.firstWhere((c) => c['name'] == 'India')),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
                            child: Text(
                              'All Countries',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                            ),
                          ),
                        ],
                        ...filtered.map((country) => buildCountryRow(country)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBody: true,
        appBar: const SanchoraPageHeader(title: 'Personal Information'),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ProfileAvatarPicker(
                      initials: 'HP',
                      name: _origName,
                      email: _origEmail,
                      onCameraTap: () {},
                      onGalleryTap: () {},
                      onRemoveTap: () {},
                    ),
                    const SizedBox(height: 20),
                    
                    const SectionHeader(title: 'Basic Information'),
                    PremiumInputCard(
                      label: 'Full Name *',
                      icon: Icons.person_rounded,
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      errorText: _nameError,
                      focusNode: _nameFocus,
                    ),
                    PremiumInputCard(
                      label: 'Email *',
                      icon: Icons.email_rounded,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Enter your email address',
                      errorText: _emailError,
                      focusNode: _emailFocus,
                    ),
                    PremiumInputCard(
                      label: 'Phone',
                      icon: Icons.phone_rounded,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      hintText: 'Enter your phone number',
                      errorText: _phoneError,
                      focusNode: _phoneFocus,
                      inputFormatters: [
                        PhoneInputFormatter(getCountry: () => _countryController.text),
                      ],
                    ),
                    PremiumSelectorCard(
                      label: 'Date of Birth',
                      icon: Icons.cake_rounded,
                      value: _dobController.text,
                      subtitle: _dobAgeText,
                      hintText: 'DD MMM YYYY',
                      onTap: _showDobPicker,
                    ),
                    PremiumSelectorCard(
                      label: 'Gender',
                      icon: Icons.wc_rounded,
                      value: _genderController.text,
                      hintText: 'Select gender',
                      onTap: _showGenderPicker,
                    ),
                    PremiumSelectorCard(
                      label: 'Country',
                      icon: Icons.public_rounded,
                      value: _countryController.text,
                      hintText: 'Enter country',
                      onTap: _showCountrySelector,
                    ),
                    PremiumSelectorCard(
                      label: 'Language',
                      icon: Icons.language_rounded,
                      value: _languageController.text,
                      hintText: 'Select language',
                      onTap: _showLanguagePicker,
                    ),
                    
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'Account Information'),
                    const PremiumInfoCard(
                      rows: [
                        PremiumInfoRow(icon: Icons.calendar_month_rounded, label: 'Member Since', value: 'October 2023'),
                        PremiumInfoRow(icon: Icons.fingerprint_rounded, label: 'Account ID', value: 'SNC-8472-9104'),
                        PremiumInfoRow(icon: Icons.login_rounded, label: 'Sign-in Method', value: 'Google OAuth'),
                        PremiumInfoRow(icon: Icons.info_outline_rounded, label: 'App Version', value: '2.4.1 (492)'),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Security'),
                    _buildSettingsTile(
                      context,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      context,
                      title: 'Connected Accounts',
                      subtitle: 'Manage Google, Apple & Email accounts',
                      icon: Icons.link_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConnectedAccountsScreen(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Preferences'),
                    _buildPreferenceCard(
                      context,
                      title: 'Communication Email',
                      subtitle: 'Receive important account updates',
                      icon: Icons.mark_email_unread_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      value: _commEmail,
                      onChanged: (val) {
                        setState(() => _commEmail = val);
                        _checkChanges();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPreferenceCard(
                      context,
                      title: 'Marketing Emails',
                      subtitle: 'Offers, promotions, and newsletter',
                      icon: Icons.campaign_rounded,
                      iconColor: const Color(0xFFEC4899),
                      value: _mktEmail,
                      onChanged: (val) {
                        setState(() => _mktEmail = val);
                        _checkChanges();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPreferenceCard(
                      context,
                      title: 'Product Updates',
                      subtitle: 'New features and changelog',
                      icon: Icons.new_releases_rounded,
                      iconColor: const Color(0xFF10B981),
                      value: _updates,
                      onChanged: (val) {
                        setState(() => _updates = val);
                        _checkChanges();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildGlassmorphicBottomBar(theme, isDark),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withValues(alpha: 0.15) : iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 24, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.15) : iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicBottomBar(ThemeData theme, bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding == 0 ? 20 : bottomPadding + 8),
          decoration: BoxDecoration(
            color: isDark 
                ? theme.scaffoldBackgroundColor.withValues(alpha: 0.75) 
                : theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.2) : const Color(0xFFE8E8E8).withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Opacity(
            opacity: (_hasChanges && _isValid) ? 1.0 : 0.5,
            child: SanchoraButton(
              label: 'Save Changes',
              isPrimary: true,
              onPressed: (_hasChanges && _isValid) ? _onSave : null,
            ),
          ),
        ),
      ),
    );
  }
}
