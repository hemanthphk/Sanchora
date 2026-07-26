import 'package:flutter/material.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/features/subscriptions/models/subscription_preset_model.dart';
import 'package:sanchora/features/subscriptions/services/subscription_preset_service.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';
import 'package:sanchora/features/subscriptions/services/subscription_icon_registry.dart';
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
    "Shopping",
    "Productivity",
    "AI",
    "Gaming",
    "Finance",
    "Education",
    "Health",
    "Other",
  ];

  String _selectedCycle = "Monthly";
  final List<String> _billingCycles = ["Monthly", "Yearly"];

  DateTime _startDate = DateTime.now();
  late DateTime _renewalDate;
  bool _reminderEnabled = true;
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
    final iconUrl = SubscriptionIconRegistry.getIconUrl(presetMatch?.iconKey ?? name);

    final id = _isEditMode ? widget.subscriptionToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString();

    final subModel = SubscriptionModel(
      id: id,
      name: name,
      category: _selectedCategory,
      monthlyPrice: monthlyPrice,
      yearlyPrice: yearlyPrice,
      billingCycle: _selectedCycle == "Monthly" ? BillingCycle.monthly : BillingCycle.yearly,
      nextRenewalDate: _renewalDate,
      status: status,
      iconUrl: iconUrl,
      hasReminder: _reminderEnabled,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          _isEditMode ? 'Edit Subscription' : 'Add Subscription',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (_showSuggestions) setState(() => _showSuggestions = false);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Subscription Name"),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: "e.g., Netflix",
                      suffixIcon: _nameController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter a name";
                      }
                      return null;
                    },
                  ),
                  _buildSuggestionsList(theme),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle("Price"),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: "0.00",
                      prefixText: "${CurrencyFormatter.format(0).substring(0, 1)} ",
                      helperText: _priceController.text.trim().isNotEmpty && double.tryParse(_priceController.text.trim()) != null
                          ? "Formatted: ${CurrencyFormatter.format(double.tryParse(_priceController.text.trim()) ?? 0)} / ${_selectedCycle == 'Monthly' ? 'mo' : 'yr'}"
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter price";
                      }
                      if ((double.tryParse(value.trim()) ?? 0) <= 0) {
                        return "Invalid amount";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Category"),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                    dropdownColor: theme.cardTheme.color ?? theme.colorScheme.surface,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                        _validateForm();
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Billing Cycle"),
                  Row(
                    children: _billingCycles.map((cycle) {
                      final selected = _selectedCycle == cycle;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => _updateRenewalDate(cycle),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
                                  width: selected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Text(
                                cycle,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Remind Me",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Get notified before payment",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _reminderEnabled,
                          onChanged: (val) => setState(() => _reminderEnabled = val),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Notes (Optional)"),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: "Add any notes or details here...",
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: theme.colorScheme.outline),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isFormValid ? _saveSubscription : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            disabledBackgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                            disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            _isEditMode ? "Update Subscription" : "Save Subscription",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
            ),
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
      ],
    );
  }
}