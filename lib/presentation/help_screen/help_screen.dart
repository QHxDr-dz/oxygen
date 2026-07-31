import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<_FaqItem> _faqs = const [
    _FaqItem(
      question: 'How do I start a workout?',
      answer:
          'Go to the "Programs" tab, select your assigned program, and tap "Start Workout" on any available day. The workout player will guide you through each exercise.',
    ),
    _FaqItem(
      question: 'How do I track my sets?',
      answer:
          'During a workout session, tap the checkmark button after completing each set. The app will automatically track your progress and update your completion percentage.',
    ),
    _FaqItem(
      question: 'Can I pause a workout?',
      answer:
          'Yes, you can pause a workout at any time by pressing the back button. Your progress will be saved and you can resume from where you left off.',
    ),
    _FaqItem(
      question: 'How do I view my workout history?',
      answer:
          'Navigate to the "History" tab in the bottom navigation bar to see all your completed workout sessions with detailed statistics.',
    ),
    _FaqItem(
      question: 'How do I update my profile?',
      answer:
          'Go to the "Profile" tab and tap the edit icon in the top right corner. You can update your name, photo, and fitness goals.',
    ),
    _FaqItem(
      question: 'What does my subscription include?',
      answer:
          'Your subscription gives you access to personalized workout programs, progress tracking, and all premium features. Check the "Subscription" screen for details about your current plan.',
    ),
    _FaqItem(
      question: 'How do I contact my trainer?',
      answer:
          'Contact information for your trainer is available through the gym management. You can also reach out to our support team at support@oxygenclub.app.',
    ),
  ];

  final Set<int> _expandedItems = {};

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
                      'Help & Support',
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
                    // Contact card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withAlpha(40),
                            AppTheme.secondary.withAlpha(40),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primary.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              color: AppTheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need more help?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimaryDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'support@oxygenclub.app',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'FREQUENTLY ASKED QUESTIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMutedDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.borderDark,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: _faqs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final faq = entry.value;
                          final isExpanded = _expandedItems.contains(index);
                          final isLast = index == _faqs.length - 1;

                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedItems.remove(index);
                                    } else {
                                      _expandedItems.add(index);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          faq.question,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isExpanded
                                                ? AppTheme.primary
                                                : AppTheme.textPrimaryDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: isExpanded
                                            ? AppTheme.primary
                                            : AppTheme.textMutedDark,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Text(
                                    faq.answer,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondaryDark,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              if (!isLast)
                                const Divider(
                                  height: 1,
                                  color: AppTheme.borderDark,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
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

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
