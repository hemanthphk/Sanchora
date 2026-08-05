import 'package:flutter/material.dart';

import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/features/subscriptions/models/subscription_preset_model.dart';
import 'package:sanchora/features/subscriptions/services/subscription_preset_service.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';
import 'package:sanchora/features/subscriptions/widgets/subscription_icon.dart';

class AddSubscriptionPage extends StatefulWidget {
  const AddSubscriptionPage({
    super.key,
    this.subscriptionToEdit,
  });

  final SubscriptionModel? subscriptionToEdit;

  @override
  State<AddSubscriptionPage> createState() => _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends State<AddSubscriptionPage> {
  bool get _isEditMode => widget.subscriptionToEdit != null;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCategory = "Streaming";
  final List<String> _categories = [
    "Streaming",
    "Music",
    "Gaming",
    "Cloud Storage",
    "Design",
    "Productivity",
    "Education",
    "Finance",
    "Shopping",
    "Food",
    "Fitness",
    "Security",
    "Other",
  ];

  String _selectedCycle = "Monthly";
  final List<String> _billingCycles = ["Monthly", "Yearly"];

  DateTime _startDate = DateTime.now();
  late DateTime _renewalDate;
  bool _reminderEnabled = true;
  bool _isTrial = false;
  bool _isFormValid = false;
  
  final SubscriptionPresetService _presetService = const SubscriptionPresetService();
  List<SubscriptionPresetModel> _suggestions = [];
  bool _showSuggestions = false;
  bool _isSelectingPreset = false;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final sub = widget.subscriptionToEdit!;
      _nameController.text = sub.name;
      if (_categories.contains(sub.category)) {
        _selectedCategory = sub.category;
      } else {
        _categories.add(sub.category);
        _selectedCategory = sub.category;
      }
      _selectedCycle = sub.billingCycle == BillingCycle.monthly ? "Monthly" : "Yearly";
      _priceController.text = sub.currentPrice == sub.currentPrice.roundToDouble()
          ? sub.currentPrice.toInt().toString()
          : sub.currentPrice.toString();
      _renewalDate = sub.nextRenewalDate;
      if (_selectedCycle == "Monthly") {
        _startDate = DateTime(_renewalDate.year, _renewalDate.month - 1, _renewalDate.day);
      } else {
        _startDate = DateTime(_renewalDate.year - 1, _renewalDate.month, _renewalDate.day);
      }
      _reminderEnabled = sub.hasReminder;
      _isTrial = sub.isTrial;
      if (sub.notes != null) {
        _notesController.text = sub.notes!;
      }
    } else {
      _renewalDate = _calculateRenewalDate(_startDate, _selectedCycle);
    }
    _nameController.addListener(_onNameChanged);
    _priceController.addListener(() {
      setState(() {});
      _validateForm();
    });
    _validateForm();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_isSelectingPreset) return;
    final query = _nameController.text.trim();
    if (query.isNotEmpty) {
      final matches = _presetService.searchPresets(query);
      final exactMatch = _presetService.findPresetByName(query);
      if (exactMatch != null) {
        if (_showSuggestions) {
          setState(() {
            _showSuggestions = false;
            _suggestions = [];
          });
        }
      } else {
        setState(() {
          _suggestions = matches;
          _showSuggestions = matches.isNotEmpty;
        });
      }
    } else {
      if (_showSuggestions) {
        setState(() {
          _showSuggestions = false;
          _suggestions = [];
        });
      }
    }
    _validateForm();
  }

  void _onPresetSelected(SubscriptionPresetModel preset) {
    _isSelectingPreset = true;
    FocusScope.of(context).unfocus();
    _nameController.text = preset.name;
    setState(() {
      _selectedCategory = preset.defaultCategory;
      _selectedCycle = preset.defaultBillingCycle;
      _showSuggestions = false;
      _suggestions = [];
    });
    _isSelectingPreset = false;
    _validateForm();
  }

  Widget _buildSuggestionsList(ThemeData theme) {
    if (!_showSuggestions || _suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
          itemBuilder: (context, index) {
            final preset = _suggestions[index];
            return InkWell(
              onTap: () => _onPresetSelected(preset),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SubscriptionIcon(
                      iconIdentifier: preset.iconKey ?? preset.name,
                      fallbackName: preset.name,
                      category: preset.defaultCategory,
                      size: 36,
                      borderRadius: 10,
                      backgroundColor: (preset.brandColor ?? theme.colorScheme.primary).withValues(alpha: 0.15),
                      textColor: preset.brandColor ?? theme.colorScheme.primary,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: preset.brandColor ?? theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${preset.defaultCategory} • ${preset.defaultBillingCycle}",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _validateForm() {
    final nameValid = _nameController.text.trim().isNotEmpty;
    final priceText = _priceController.text.trim();
    final priceValid = priceText.isNotEmpty && (double.tryParse(priceText) ?? 0) > 0;
    final valid = nameValid && priceValid && _selectedCategory.isNotEmpty;
    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  void _saveSubscription() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final isDuplicate = SubscriptionService.instance.isDuplicateName(
      name,
      excludeId: widget.subscriptionToEdit?.id,
    );

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subscription already exists."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final monthlyPrice = _selectedCycle == "Monthly" ? price : (price / 12);
    final yearlyPrice = _selectedCycle == "Yearly" ? price : (price * 12);

    final now = DateTime.now();
    SubscriptionStatus status;
    if (_renewalDate.isBefore(DateTime(now.year, now.month, now.day))) {
      status = SubscriptionStatus.expired;
    } else if (_renewalDate.difference(now).inDays <= 7) {
      status = SubscriptionStatus.upcoming;
    } else {
      status = SubscriptionStatus.active;
    }

    final presetMatch = _presetService.findPresetByName(name);
    final iconUrl = presetMatch?.iconKey ?? name;

    final id = _isEditMode ? widget.subscriptionToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString();

    final subModel = SubscriptionModel(
      id: id,
      name: name,
      category: _selectedCategory,
      monthlyPrice: monthlyPrice,
      yearlyPrice: yearlyPrice,
      billingCycle: _selectedCycle == "Monthly" ? BillingCycle.monthly : BillingCycle.yearly,
      startDate: _startDate,
      nextRenewalDate: _renewalDate,
      status: status,
      iconUrl: iconUrl,
      hasReminder: _reminderEnabled,
      isTrial: _isTrial,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (_isEditMode) {
      SubscriptionService.instance.updateSubscription(subModel);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subscription updated successfully."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context, subModel);
      }
    } else {
      SubscriptionService.instance.addSubscription(subModel);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subscription added successfully."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }
  }

  DateTime _calculateRenewalDate(DateTime start, String cycle) {
    if (cycle == "Monthly") {
      return DateTime(start.year, start.month + 1, start.day);
    } else if (cycle == "Yearly") {
      return DateTime(start.year + 1, start.month, start.day);
    }
    return start.add(const Duration(days: 30));
  }

  void _updateRenewalDate(String cycle) {
    setState(() {
      _selectedCycle = cycle;
      _renewalDate = _calculateRenewalDate(_startDate, cycle);
    });
    _validateForm();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _renewalDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _renewalDate = _calculateRenewalDate(picked, _selectedCycle);
        } else {
          _renewalDate = picked;
        }
      });
      _validateForm();
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                        _validateForm();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : Colors.transparent,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_getCategoryIcon(cat), size: 24, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Streaming': return Icons.play_circle_outline_rounded;
      case 'Music': return Icons.music_note_rounded;
      case 'Gaming': return Icons.sports_esports_outlined;
      case 'Cloud Storage': return Icons.cloud_outlined;
      case 'Design': return Icons.palette_outlined;
      case 'Productivity': return Icons.work_outline_rounded;
      case 'Education': return Icons.school_outlined;
      case 'Finance': return Icons.account_balance_wallet_outlined;
      case 'Shopping': return Icons.shopping_bag_outlined;
      case 'Food': return Icons.restaurant_outlined;
      case 'Fitness': return Icons.fitness_center_outlined;
      case 'Security': return Icons.security_outlined;
      case 'Other': return Icons.inventory_2_outlined;
      default: return Icons.inventory_2_outlined;
    }
  }

  InputDecoration _premiumInputDecoration(ThemeData theme, String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        fontSize: 15,
      ),
      prefixIcon: prefixIcon != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(prefixIcon, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: 22),
              ],
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      filled: true,
      fillColor: theme.colorScheme.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: const Color(0xFF0A84FF).withValues(alpha: 0.4), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (_showSuggestions) setState(() => _showSuggestions = false);
          },
          child: Column(
            children: [
              // Custom Premium Header
              Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isEditMode ? 'Edit Subscription' : 'Add Subscription',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Never miss a renewal again.',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: theme.colorScheme.primary.withValues(alpha: 0.9),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        
                        // Name Field
                        _buildSectionTitle("Subscription Name"),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            decoration: _premiumInputDecoration(theme, "e.g., Netflix, Spotify, ChatGPT", prefixIcon: Icons.subscriptions_outlined).copyWith(
                              suffixIcon: _nameController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel_rounded, size: 20),
                                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                      onPressed: () {
                                        _nameController.clear();
                                        setState(() {
                                          _showSuggestions = false;
                                          _suggestions = [];
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            validator: (value) => (value == null || value.trim().isEmpty) ? "" : null,
                          ),
                        ),
                        _buildSuggestionsList(theme),
                        const SizedBox(height: 24),
                        
                        // Price Field
                        _buildSectionTitle("Price"),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            decoration: _premiumInputDecoration(theme, "0.00", prefixIcon: Icons.payments_outlined).copyWith(
                              prefixText: "₹",
                              prefixStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                            ),
                            validator: (value) => ((double.tryParse(value?.trim() ?? '') ?? 0) <= 0) ? "" : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Category & Billing Cycle
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("Category"),
                                  GestureDetector(
                                    onTap: _showCategoryBottomSheet,
                                    child: _buildInputCard(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(_getCategoryIcon(_selectedCategory), size: 20, color: theme.colorScheme.primary),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _selectedCategory,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurfaceVariant),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("Billing Cycle"),
                                  Container(
                                    height: 60,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Stack(
                                      children: [
                                        AnimatedAlign(
                                          duration: const Duration(milliseconds: 250),
                                          curve: Curves.easeInOut,
                                          alignment: _selectedCycle == "Monthly" ? Alignment.centerLeft : Alignment.centerRight,
                                          child: FractionallySizedBox(
                                            widthFactor: 0.5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [const Color(0xFF0A84FF).withValues(alpha: 0.8), const Color(0xFF2563EB).withValues(alpha: 0.8)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: _billingCycles.map((cycle) {
                                            final selected = _selectedCycle == cycle;
                                            return Expanded(
                                              child: GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () => _updateRenewalDate(cycle),
                                                child: Center(
                                                  child: AnimatedDefaultTextStyle(
                                                    duration: const Duration(milliseconds: 150),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                                      color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                    ),
                                                    child: Text(cycle),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                label: "Start Date",
                                date: _startDate,
                                onTap: () => _selectDate(context, true),
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDatePicker(
                                label: "Renewal Date",
                                date: _renewalDate,
                                onTap: () => _selectDate(context, false),
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        
                        // Reminder Tile
                        _buildSectionTitle("Reminder"),
                        _buildInputCard(
                          child: InkWell(
                            onTap: () => setState(() => _reminderEnabled = !_reminderEnabled),
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.notifications_active_rounded, color: theme.colorScheme.primary, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Notify before renewal",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _reminderEnabled,
                                    onChanged: (val) => setState(() => _reminderEnabled = val),
                                    activeThumbColor: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Expandable Notes
                        Theme(
                          data: theme.copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              "Optional Notes",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _notesController,
                                  minLines: 3,
                                  maxLines: 5,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: const TextStyle(fontSize: 15),
                                  decoration: _premiumInputDecoration(theme, "Add any notes or details here..."),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isKeyboardVisible ? 16 : 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Sticky Save Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                ),
                child: InkWell(
                  onTap: _isFormValid ? _saveSubscription : null,
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: _isFormValid
                          ? const LinearGradient(
                              colors: [Color(0xFF0A84FF), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _isFormValid ? null : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                      boxShadow: _isFormValid
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _isEditMode ? "Update Subscription" : "Save Subscription",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _isFormValid ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        GestureDetector(
          onTap: onTap,
          child: _buildInputCard(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}