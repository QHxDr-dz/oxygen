import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderDark),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: January 1, 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMutedDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _PolicySection(
                      title: '1. Information We Collect',
                      content:
                          'We collect information you provide directly to us, such as when you create an account, update your profile, or contact us for support. This includes:\n\n• Name and email address\n• Fitness goals and health information\n• Workout history and performance data\n• Device information and usage data',
                    ),
                    _PolicySection(
                      title: '2. How We Use Your Information',
                      content:
                          'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Personalize your workout experience\n• Send you notifications about your workouts\n• Monitor and analyze usage patterns\n• Protect against fraudulent or illegal activity',
                    ),
                    _PolicySection(
                      title: '3. Data Security',
                      content:
                          'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. Your data is encrypted in transit and at rest.',
                    ),
                    _PolicySection(
                      title: '4. Data Retention',
                      content:
                          'We retain your personal information for as long as your account is active or as needed to provide you services. You may request deletion of your account and associated data at any time.',
                    ),
                    _PolicySection(
                      title: '5. Sharing of Information',
                      content:
                          'We do not sell, trade, or otherwise transfer your personal information to outside parties. This does not include trusted third parties who assist us in operating our application, as long as those parties agree to keep this information confidential.',
                    ),
                    _PolicySection(
                      title: '6. Your Rights',
                      content:
                          'You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Object to processing of your data\n• Data portability',
                    ),
                    _PolicySection(
                      title: '7. Contact Us',
                      content:
                          'If you have any questions about this Privacy Policy, please contact us at:\n\nprivacy@oxygenclub.app\n\nOxygen Club\nFitness Management Platform',
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryDark,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
