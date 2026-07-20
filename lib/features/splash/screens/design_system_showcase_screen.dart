import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/sanchora_button.dart';
import '../../../core/widgets/sanchora_card.dart';
import '../../../core/widgets/sanchora_text_field.dart';

class DesignSystemShowcaseScreen extends StatelessWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sanchora', style: AppTextStyles.largeTitle),
              const SizedBox(height: 8),
              Text(
                'One App. Every Subscription.',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 24),
              SanchoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Premium subscription management designed to feel effortless.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 20),
                    SanchoraButton(label: 'Continue', icon: Icons.arrow_forward_rounded, onPressed: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Design system', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 12),
              SanchoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reusable widgets', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 12),
                    const SanchoraTextField(
                      label: 'Email',
                      hintText: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 14),
                    SanchoraButton(label: 'Primary', onPressed: () {}),
                    const SizedBox(height: 12),
                    SanchoraButton(label: 'Secondary', isPrimary: false, onPressed: () {}),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle, color: AppColors.accent),
                                const SizedBox(height: 8),
                                Text('Track renewals', style: AppTextStyles.cardTitle),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.insights, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text('Analytics', style: AppTextStyles.cardTitle),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
