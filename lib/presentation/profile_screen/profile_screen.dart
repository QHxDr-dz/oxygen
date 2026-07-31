import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../features/authentication/domain/entities/auth_entities.dart';
import '../../features/authentication/presentation/providers/auth_notifier.dart';
import '../../features/subscription/presentation/providers/subscription_state_notifier.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).initialize();
      ref.read(subscriptionNotifierProvider.notifier).loadSubscription();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppTheme.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go(AppRoutes.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final subState = ref.watch(subscriptionNotifierProvider);

    if (!authState.isInitialized) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final user = authState.user;
    final member = authState.member;
    final subscription = subState.subscription;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push(AppRoutes.settingsScreen),
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppTheme.textSecondaryDark,
                      ),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
            ),

            // ── Avatar + Name + Email + Code ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  children: [
                    _AvatarWidget(user: user, member: member),
                    const SizedBox(height: 16),
                    Text(
                      member?.name.isNotEmpty == true
                          ? member!.name
                          : (user?.name ?? 'Member'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member?.email.isNotEmpty == true
                          ? member!.email
                          : (user?.email ?? ''),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryDark,
                      ),
                    ),
                    if (member != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatusBadge(isActive: member.isActive),
                          const SizedBox(width: 8),
                          _CodeBadge(code: member.code),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── QR Code Card ─────────────────────────────────────────────
            if (member?.qrToken != null && member!.qrToken!.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _QrCard(member: member),
                ),
              ),

            // ── Subscription Card ─────────────────────────────────────────
            if (subscription != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A5F), Color(0xFF2D1B69)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.card_membership_rounded,
                          color: AppTheme.accent,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subscription.plan.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${subscription.daysLeft} days remaining',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(160),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            subscription.isOngoing ? 'Active' : 'Expired',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subscription.isOngoing
                                  ? AppTheme.success
                                  : AppTheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Member Details ────────────────────────────────────────────
            if (member != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _MemberDetailsCard(member: member),
                ),
              ),

            // ── Account Menu ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMutedDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MenuSection(
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profile',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.lock_outline_rounded,
                          label: 'Change Password',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MEMBERSHIP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMutedDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MenuSection(
                      items: [
                        _MenuItem(
                          icon: Icons.card_membership_rounded,
                          label: 'Subscription',
                          onTap: () =>
                              context.push(AppRoutes.subscriptionScreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SUPPORT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMutedDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MenuSection(
                      items: [
                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          label: 'About',
                          onTap: () => context.push(AppRoutes.aboutScreen),
                        ),
                        _MenuItem(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy Policy',
                          onTap: () => context.push(AppRoutes.privacyScreen),
                        ),
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Help & Support',
                          onTap: () => context.push(AppRoutes.helpScreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _handleLogout,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withAlpha(15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.error.withAlpha(50),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: AppTheme.error,
                              size: 20,
                            ),
                            SizedBox(width: 14),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Avatar Widget
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final UserEntity? user;
  final MemberEntity? member;

  const _AvatarWidget({this.user, this.member});

  String get _photoUrl {
    if (member?.photo != null && member!.photo!.isNotEmpty) {
      return member!.photo!;
    }
    if (user?.photo != null && user!.photo!.isNotEmpty) {
      return user!.photo!;
    }
    return '';
  }

  String get _initials {
    final name = member?.name.isNotEmpty == true
        ? member!.name
        : (user?.name ?? 'U');
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(60),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: _photoUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: _photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _fallback,
                errorWidget: (_, __, ___) => _fallback,
              ),
            )
          : _fallback,
    );
  }

  Widget get _fallback => Center(
    child: Text(
      _initials,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppTheme.success : AppTheme.error).withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isActive ? AppTheme.success : AppTheme.error).withAlpha(80),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppTheme.success : AppTheme.error,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? AppTheme.success : AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Code Badge
// ─────────────────────────────────────────────────────────────────────────────

class _CodeBadge extends StatelessWidget {
  final String code;
  const _CodeBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withAlpha(80)),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium QR Card
// ─────────────────────────────────────────────────────────────────────────────

class _QrCard extends StatelessWidget {
  final MemberEntity member;
  const _QrCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.primary.withAlpha(60), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(30),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withAlpha(40),
                  AppTheme.secondary.withAlpha(20),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Member QR Code',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                      Text(
                        'Scan to verify membership',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: member.qrToken ?? ''),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: AppTheme.textSecondaryDark,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // QR Code
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: PrettyQrView.data(
                    data: member.qrToken!,
                    decoration: const PrettyQrDecoration(
                      shape: PrettyQrSmoothSymbol(color: Color(0xFF0F172A)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Member code below QR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withAlpha(60)),
                  ),
                  child: Text(
                    member.code,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Member ID',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMutedDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Member Details Card
// ─────────────────────────────────────────────────────────────────────────────

class _MemberDetailsCard extends StatelessWidget {
  final MemberEntity member;
  const _MemberDetailsCard({required this.member});

  String _capitalize(String? value) {
    if (value == null || value.isEmpty) return '';
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final details = <_DetailRow>[];

    if (member.goal.isNotEmpty) {
      details.add(
        _DetailRow(
          icon: Icons.flag_outlined,
          label: 'Goal',
          value: _capitalize(member.goal),
        ),
      );
    }
    if (member.gender != null && member.gender!.isNotEmpty) {
      details.add(
        _DetailRow(
          icon: Icons.person_outline_rounded,
          label: 'Gender',
          value: _capitalize(member.gender),
        ),
      );
    }
    if (member.contact != null && member.contact!.isNotEmpty) {
      details.add(
        _DetailRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: member.contact!,
        ),
      );
    }
    if (member.address != null && member.address!.isNotEmpty) {
      details.add(
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: member.address!,
        ),
      );
    }
    if (member.city != null && member.city!.isNotEmpty) {
      details.add(
        _DetailRow(
          icon: Icons.location_city_outlined,
          label: 'City',
          value: member.city!,
        ),
      );
    }
    if (member.country != null && member.country!.isNotEmpty) {
      details.add(
        _DetailRow(
          icon: Icons.public_outlined,
          label: 'Country',
          value: member.country!,
        ),
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MEMBER DETAILS',
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
            border: Border.all(color: AppTheme.borderDark, width: 0.5),
          ),
          child: Column(
            children: details.asMap().entries.map((entry) {
              final i = entry.key;
              final row = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(row.icon, size: 18, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 72,
                          child: Text(
                            row.label,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMutedDark,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            row.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < details.length - 1)
                    const Divider(
                      height: 1,
                      color: AppTheme.borderDark,
                      indent: 46,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu Section & Item
// ─────────────────────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark, width: 0.5),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (i < items.length - 1)
                const Divider(
                  height: 1,
                  color: AppTheme.borderDark,
                  indent: 52,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondaryDark),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppTheme.textMutedDark,
            ),
          ],
        ),
      ),
    );
  }
}
