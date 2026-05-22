import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iprakriti/models/question_model.dart';

import '../core/theme.dart';
import '../models/user_profile_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/result_service.dart';
import 'assessment_intro_screen.dart';
import 'detailed_report_screen.dart';
import 'dosha_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'profile_settings_screens.dart';

final dashboardResultsProvider =
    FutureProvider.autoDispose<List<PrakritiHistoryEntry>>((ref) async {
      final userId = ref.watch(authControllerProvider).session?.user.id;
      if (userId == null) {
        return [];
      }

      return ref.watch(resultServiceProvider).fetchResults(userId);
    });

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

const _dashboardNavBarOverlayHeight = 124.0;

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthViewState>(authControllerProvider, (previous, next) {
      final hadSession = previous?.session != null;
      final hasSession = next.session != null;
      if (!hasSession) {
        ref.read(profileAvatarOverrideProvider.notifier).state = null;
      }
      if (hadSession && !hasSession && context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });

    final screens = [
      _HomeTab(
        onOpenReports: () => _selectTab(1),
        onOpenLearn: () => _selectTab(2),
      ),
      const _ReportsTab(),
      const _LearnTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFA),
      extendBody: true,
      body: Stack(
        children: [
          SafeArea(
            child: IndexedStack(index: _selectedIndex, children: screens),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 14,
            child: SafeArea(
              top: false,
              child: _BottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: _selectTab,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.onOpenReports, required this.onOpenLearn});

  final VoidCallback onOpenReports;
  final VoidCallback onOpenLearn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.session?.user;
    final profile = ref
        .watch(currentUserProfileProvider)
        .maybeWhen(data: (profile) => profile, orElse: () => null);
    final avatarOverride = ref.watch(profileAvatarOverrideProvider);
    final fullName = _displayName(user, profile);
    final avatarUrl = avatarOverride ?? _avatarUrl(user, profile);
    final greeting = _greetingForNow();
    final resultsAsync = ref.watch(dashboardResultsProvider);

    return resultsAsync.when(
      data:
          (results) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              26,
              24,
              26,
              _dashboardNavBarOverlayHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(
                  greeting: greeting,
                  fullName: fullName,
                  avatarUrl: avatarUrl,
                ),
                const SizedBox(height: 26),
                _AssessmentHero(onPressed: () => _openAssessment(context)),
                if (results.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _LatestResultCard(entry: results.first, onTap: onOpenReports),
                ],
                const SizedBox(height: 20),
                const _AyurvedicTipCard(),
                const SizedBox(height: 22),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1.12,
                  children: [
                    _QuickActionCard(
                      label: 'Daily Routine',
                      icon: Icons.menu_book_rounded,
                      tint: const Color(0xFFE8ECE3),
                      onTap: () => _showRoutineDialog(context),
                    ),
                    _QuickActionCard(
                      label: 'Learn Doshas',
                      icon: Icons.spa_outlined,
                      tint: const Color(0xFFF8EFC5),
                      onTap: onOpenLearn,
                    ),
                    _QuickActionCard(
                      label: 'Retake Test',
                      icon: Icons.refresh_rounded,
                      tint: const Color(0xFFE8D9FA),
                      onTap: () => _openAssessment(context),
                    ),
                    _QuickActionCard(
                      label: 'View All Reports',
                      icon: Icons.description_outlined,
                      tint: const Color(0xFFD9EEFF),
                      onTap: onOpenReports,
                    ),
                  ],
                ),
              ],
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
    );
  }

  static void _openAssessment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AssessmentIntroScreen()),
    );
  }

  static void _showRoutineDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Daily Routine'),
            content: const Text(
              'Begin with warm water, eat at regular times, take a short walk after meals, and wind down with a calm evening routine.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(dashboardResultsProvider);

    return resultsAsync.when(
      data:
          (items) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              26,
              26,
              26,
              _dashboardNavBarOverlayHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Reports',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track your Prakruti journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5A5A5A),
                  ),
                ),
                const SizedBox(height: 26),
                if (items.isEmpty)
                  _EmptyReportsCard(
                    onStartAssessment:
                        () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AssessmentIntroScreen(),
                          ),
                        ),
                  )
                else ...[
                  _TrendCard(items: items),
                  const SizedBox(height: 24),
                  Text(
                    'Assessment History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ReportCard(item: item),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const _ReportsHintCard(),
                ],
              ],
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
    );
  }
}

class _LearnTab extends StatelessWidget {
  const _LearnTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        26,
        26,
        26,
        _dashboardNavBarOverlayHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn Ayurveda',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Understand your natural body constitution',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF242424)),
          ),
          const SizedBox(height: 50),
          _LearnDoshaCard(
            title: 'Vata',
            subtitle: 'Air & Space • Creative, quick, sensitive',
            backgroundColor: const Color(0xFFDDF8FF),
            iconBackgroundColor: const Color(0xFFC9F2FF),
            iconColor: const Color(0xFF5288E7),
            icon: Icons.air_rounded,
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DoshaDetailsScreen(dosha: Dosha.vata),
                  ),
                ),
          ),
          const SizedBox(height: 12),
          _LearnDoshaCard(
            title: 'Pitta',
            subtitle: 'Fire & Water • Sharp, driven, focused',
            backgroundColor: const Color(0xFFFFEBCF),
            iconBackgroundColor: const Color(0xFFFFCDB4),
            iconColor: const Color(0xFFFF5A2D),
            icon: Icons.local_fire_department_outlined,
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder:
                        (_) => const DoshaDetailsScreen(dosha: Dosha.pitta),
                  ),
                ),
          ),
          const SizedBox(height: 12),
          _LearnDoshaCard(
            title: 'Kapha',
            subtitle: 'Earth & Water • Stable, calm, grounded',
            backgroundColor: const Color(0xFFD9FFD1),
            iconBackgroundColor: const Color(0xFFADF8B6),
            iconColor: const Color(0xFF65C879),
            icon: Icons.water_drop_outlined,
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder:
                        (_) => const DoshaDetailsScreen(dosha: Dosha.kapha),
                  ),
                ),
          ),
          const SizedBox(height: 30),
          const _PrakrutiInfoCard(),
          const SizedBox(height: 14),
          _LearnAssessmentCard(
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AssessmentIntroScreen(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _LearnDoshaCard extends StatelessWidget {
  const _LearnDoshaCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 103,
        padding: const EdgeInsets.fromLTRB(19, 18, 23, 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 33),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontSize: 11,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9EA39D),
              size: 34,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrakrutiInfoCard extends StatelessWidget {
  const _PrakrutiInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8FFE1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF79C56F),
                  size: 22,
                ),
              ),
              const SizedBox(width: 22),
              Text(
                'What is Prakruti ?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            'Prakruti is your unique Ayurvedic body constitution determined at conception. It represents the natural balance of the three doshas—Vata, Pitta, and Kapha—in your body and mind.\n\nUnderstanding your Prakruti helps you make better choices for your diet, lifestyle, and wellness practices that align with your natural tendencies.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black, height: 1.33),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE8E8E8), height: 1),
          const SizedBox(height: 14),
          Text(
            'Key Benefits:\n'
            ' • Personalized diet and nutrition\n'
            '   guidance\n'
            ' • Lifestyle recommendations tailored to\n'
            '   you\n'
            ' • Better understanding of health patterns\n'
            ' • Enhanced mind-body awareness',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black, height: 1.27),
          ),
        ],
      ),
    );
  }
}

class _LearnAssessmentCard extends StatelessWidget {
  const _LearnAssessmentCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE8DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to discover your Prakruti?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take our AI-powered assessment to understand your\nunique constitution.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black, height: 1.25),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16641F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start Assessment',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.session?.user;
    final profile = ref
        .watch(currentUserProfileProvider)
        .maybeWhen(data: (profile) => profile, orElse: () => null);
    final avatarOverride = ref.watch(profileAvatarOverrideProvider);
    final fullName = _displayName(user, profile);
    final avatarUrl = avatarOverride ?? _avatarUrl(user, profile);
    final email = _displayEmail(user, profile);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        26,
        24,
        26,
        _dashboardNavBarOverlayHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _ProfileHeaderCard(
            fullName: fullName,
            email: email,
            avatarUrl: avatarUrl,
            onEdit: () async {
              final result = await Navigator.of(context)
                  .push<EditProfileSaveResult>(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (result != null) {
                ref.invalidate(currentUserProfileProvider);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              }
            },
          ),
          const SizedBox(height: 18),
          _ProfileMenuCard(
            items: [
              _ProfileMenuItemData(
                title: 'Notification Preferences',
                icon: Icons.notifications_none_rounded,
                tint: const Color(0xFFEAF9E7),
                onTap:
                    () => _openProfileScreen(
                      context,
                      const NotificationPreferencesScreen(),
                    ),
              ),
              _ProfileMenuItemData(
                title: 'Terms & Conditions',
                icon: Icons.settings_outlined,
                tint: const Color(0xFFEAF9E7),
                onTap:
                    () => _openProfileScreen(
                      context,
                      const TermsConditionsScreen(),
                    ),
              ),
              _ProfileMenuItemData(
                title: 'Privacy Policy',
                icon: Icons.shield_outlined,
                tint: const Color(0xFFEAF9E7),
                onTap:
                    () => _openProfileScreen(
                      context,
                      const PrivacyPolicyScreen(),
                    ),
              ),
              _ProfileMenuItemData(
                title: 'About App',
                icon: Icons.info_outline_rounded,
                tint: const Color(0xFFEAF9E7),
                onTap:
                    () => _openProfileScreen(context, const AboutAppScreen()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileMenuCard(
            items: [
              _ProfileMenuItemData(
                title: 'Logout',
                icon: Icons.logout_rounded,
                tint: const Color(0xFFFCE7E6),
                iconColor: const Color(0xFFFF4A3D),
                onTap:
                    () => _confirmLogout(
                      context,
                      ref,
                      isLoading: authState.isLoading,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProfileScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref, {
    required bool isLoading,
  }) async {
    if (isLoading) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('Log out'),
            content: const Text(
              'Are you sure you want to log out of your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Log out'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.fullName,
    required this.avatarUrl,
  });

  final String greeting;
  final String fullName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $fullName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Let's check your wellness today.",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF545454)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ProfileAvatar(imageUrl: avatarUrl, fallbackLabel: fullName),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.fallbackLabel,
    this.size = 52,
  });

  final String? imageUrl;
  final String fallbackLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials =
        fallbackLabel.isEmpty
            ? 'U'
            : fallbackLabel
                .trim()
                .split(RegExp(r'\s+'))
                .take(2)
                .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
                .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: const Color(0xFFEEE7E6),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child:
            imageUrl == null
                ? Text(
                  initials,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                )
                : null,
      ),
    );
  }
}

class _AssessmentHero extends StatelessWidget {
  const _AssessmentHero({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FCEB),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Your Prakruti',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take your AI-powered assessment now',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF505050)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 56),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Start Assessment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestResultCard extends StatelessWidget {
  const _LatestResultCard({required this.entry, required this.onTap});

  final PrakritiHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = _dominantPercent(entry);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Latest Result',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _ResultRing(percent: percent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.finalPrakriti,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(entry.createdAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFEAEAE6), height: 1),
          TextButton(
            onPressed: onTap,
            child: const Text(
              'View Report',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  int _dominantPercent(PrakritiHistoryEntry entry) {
    final total = entry.vataScore + entry.pittaScore + entry.kaphaScore;
    if (total <= 0) {
      return 0;
    }
    final dominant = [
      entry.vataScore,
      entry.pittaScore,
      entry.kaphaScore,
    ].reduce((a, b) => a > b ? a : b);
    return ((dominant / total) * 100).round();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ResultRing extends StatelessWidget {
  const _ResultRing({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 3,
            backgroundColor: const Color(0xFFE8ECE7),
            color: AppColors.primary,
          ),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AyurvedicTipCard extends StatelessWidget {
  const _AyurvedicTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6EF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E6DB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Ayurvedic Tip",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your day with warm lemon water to balance Pitta and support digestion.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF505050),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFEFC),
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEFC),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF3F1EA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 22,
                offset: Offset(0, 10),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0x08FFFFFF),
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF707070), size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyReportsCard extends StatelessWidget {
  const _EmptyReportsCard({required this.onStartAssessment});

  final VoidCallback onStartAssessment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.description_outlined,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved reports yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Take your first prakruti assessment to start building your wellness history.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onStartAssessment,
            child: const Text('Start Assessment'),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.item});

  final PrakritiHistoryEntry item;

  @override
  Widget build(BuildContext context) {
    final result = PrakritiAssessmentResult(
      vataScore: item.vataScore,
      pittaScore: item.pittaScore,
      kaphaScore: item.kaphaScore,
      finalPrakriti: item.finalPrakriti,
      createdAt: item.createdAt,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailedReportScreen(result: result),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.fromLTRB(19, 16, 10, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE1E8DE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: CustomPaint(painter: _ReportRingPainter(item)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${item.finalPrakriti} Dominant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF1C1C1C),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _DeleteReportButton(item: item),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.items});

  final List<PrakritiHistoryEntry> items;

  @override
  Widget build(BuildContext context) {
    final trendItems = items.take(3).toList().reversed.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E8DE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prakruti Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 148,
            width: double.infinity,
            child: CustomPaint(painter: _PrakrutiTrendPainter(trendItems)),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Color(0xFFFFC45D), label: 'Pitta'),
              SizedBox(width: 22),
              _LegendDot(color: Color(0xFF6EA0FF), label: 'Vata'),
              SizedBox(width: 22),
              _LegendDot(color: Color(0xFF5CEB83), label: 'Kapha'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _trendMessage(trendItems),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2E2E2E),
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }

  String _trendMessage(List<PrakritiHistoryEntry> trendItems) {
    if (trendItems.length < 2) {
      return 'Take regular assessments to track your dosha balance over time.';
    }

    final first = trendItems.first;
    final last = trendItems.last;
    final dominant = last.finalPrakriti;
    final firstScore = _scoreFor(first, dominant);
    final lastScore = _scoreFor(last, dominant);
    final direction = lastScore >= firstScore ? 'increasing' : 'shifting';

    return 'Your $dominant dominance has been steadily $direction over the past ${trendItems.length} months. Consider incorporating more cooling practices.';
  }

  int _scoreFor(PrakritiHistoryEntry item, String prakriti) {
    switch (prakriti.toLowerCase()) {
      case 'vata':
        return item.vataScore;
      case 'kapha':
        return item.kaphaScore;
      case 'pitta':
      default:
        return item.pittaScore;
    }
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: const Color(0xFF5A5A5A),
          ),
        ),
      ],
    );
  }
}

class _ReportsHintCard extends StatelessWidget {
  const _ReportsHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE8D9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 16,
            color: Color(0xFFE3B85E),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Take regular assessments to track your\ndosha balance over time',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2E2E2E),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRingPainter extends CustomPainter {
  const _ReportRingPainter(this.item);

  final PrakritiHistoryEntry item;

  static const _vataColor = Color(0xFF6EA0FF);
  static const _pittaColor = Color(0xFFFFC45D);
  static const _kaphaColor = Color(0xFF5CEB83);

  @override
  void paint(Canvas canvas, Size size) {
    final total = item.vataScore + item.pittaScore + item.kaphaScore;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 3;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const gap = 0.08;
    var start = -1.5708;

    final trackPaint =
        Paint()
          ..color = const Color(0xFFF4F4F4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (total == 0) {
      return;
    }

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    final segments = [
      (item.kaphaScore, _kaphaColor),
      (item.pittaScore, _pittaColor),
      (item.vataScore, _vataColor),
    ];

    for (final segment in segments) {
      final sweep = (segment.$1 / total) * 6.28318;
      if (sweep <= 0) {
        continue;
      }

      paint.color = segment.$2;
      canvas.drawArc(rect, start, (sweep - gap).clamp(0, sweep), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _ReportRingPainter oldDelegate) {
    return oldDelegate.item != item;
  }
}

class _PrakrutiTrendPainter extends CustomPainter {
  const _PrakrutiTrendPainter(this.items);

  final List<PrakritiHistoryEntry> items;

  static const _vataColor = Color(0xFF6EA0FF);
  static const _pittaColor = Color(0xFFFFC45D);
  static const _kaphaColor = Color(0xFF5CEB83);

  @override
  void paint(Canvas canvas, Size size) {
    final left = 58.0;
    final top = 4.0;
    final right = size.width - 48;
    final bottom = size.height - 24;
    final chart = Rect.fromLTRB(left, top, right, bottom);

    final gridPaint =
        Paint()
          ..color = const Color(0xFFE6E6E6)
          ..strokeWidth = 1;
    final axisPaint =
        Paint()
          ..color = const Color(0xFFBDBDBD)
          ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = chart.bottom - (chart.height * i / 4);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _drawText(
        canvas,
        '${i * 25}',
        Offset(chart.left - 18, y - 5),
        fontSize: 7,
        color: Colors.black,
        align: TextAlign.right,
        width: 16,
      );
    }

    final columns = items.length <= 1 ? 1 : items.length - 1;
    for (var i = 0; i < items.length; i++) {
      final x = chart.left + (chart.width * i / columns);
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), gridPaint);
      _drawText(
        canvas,
        _monthLabel(items[i].createdAt),
        Offset(x - 11, chart.bottom + 7),
        fontSize: 7,
        color: Colors.black,
        width: 22,
      );
    }

    canvas.drawLine(
      Offset(chart.left, chart.bottom),
      Offset(chart.right, chart.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chart.left, chart.top),
      Offset(chart.left, chart.bottom),
      axisPaint,
    );

    if (items.isEmpty) {
      return;
    }

    _drawSeries(
      canvas,
      chart,
      columns,
      items.map((e) => e.pittaScore).toList(),
      _pittaColor,
    );
    _drawSeries(
      canvas,
      chart,
      columns,
      items.map((e) => e.vataScore).toList(),
      _vataColor,
    );
    _drawSeries(
      canvas,
      chart,
      columns,
      items.map((e) => e.kaphaScore).toList(),
      _kaphaColor,
    );
  }

  void _drawSeries(
    Canvas canvas,
    Rect chart,
    int columns,
    List<int> values,
    Color color,
  ) {
    final linePaint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = chart.left + (chart.width * i / columns);
      final y = chart.bottom - chart.height * (values[i].clamp(0, 100) / 100);
      final point = Offset(x, y);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawCircle(point, 4, dotPaint);
    }

    canvas.drawPath(path, linePaint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double fontSize,
    required Color color,
    TextAlign align = TextAlign.center,
    double width = 40,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);

    painter.paint(canvas, offset);
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }

  @override
  bool shouldRepaint(covariant _PrakrutiTrendPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.onEdit,
  });

  final String fullName;
  final String email;
  final String? avatarUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEAEDE3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ProfileAvatar(
                imageUrl: avatarUrl,
                fallbackLabel: fullName,
                size: 80,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF444444),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 46),
                backgroundColor: const Color(0xFFE7FAE4),
                foregroundColor: const Color(0xFF507D35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({required this.items});

  final List<_ProfileMenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEAEDE3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _ProfileMenuRow(item: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, color: Color(0xFFEAEDE3)),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({required this.item});

  final _ProfileMenuItemData item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.iconColor ?? const Color(0xFF83B95C),
                size: 21,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItemData {
  const _ProfileMenuItemData({
    required this.title,
    required this.icon,
    required this.tint,
    required this.onTap,
    this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color tint;
  final Color? iconColor;
  final VoidCallback onTap;
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.home_rounded,
            isActive: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _BottomNavItem(
            icon: Icons.description_outlined,
            isActive: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          _BottomNavItem(
            icon: Icons.menu_book_outlined,
            isActive: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            isActive: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Icon(
        icon,
        color: isActive ? Colors.black : const Color(0xFFADADAD),
        size: 26,
      ),
    );
  }
}

class _DeleteReportButton extends ConsumerWidget {
  const _DeleteReportButton({required this.item});

  final PrakritiHistoryEntry item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Report'),
                content: Text(
                  'Delete the ${item.finalPrakriti} report from ${_formatDate(item.createdAt)}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
        );

        if (shouldDelete != true || !context.mounted) {
          return;
        }

        try {
          await ref.read(resultServiceProvider).deleteResult(item.id);
          ref.invalidate(dashboardResultsProvider);
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report deleted successfully.')),
          );
        } catch (error) {
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      },
      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9A9A9A)),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

String _displayName(dynamic user, [UserProfileData? profile]) {
  final profileName = profile?.name;
  if (profileName != null && profileName.isNotEmpty) {
    return profileName;
  }

  final fullName = user?.userMetadata?['full_name'] as String?;
  final name = user?.userMetadata?['name'] as String?;
  final emailPrefix = user?.email?.split('@').first;
  return fullName ?? name ?? emailPrefix ?? 'Wellness Seeker';
}

String _displayEmail(dynamic user, [UserProfileData? profile]) {
  final profileEmail = profile?.email;
  if (profileEmail != null && profileEmail.isNotEmpty) {
    return profileEmail;
  }
  return user?.email ?? 'No email available';
}

String? _avatarUrl(dynamic user, [UserProfileData? profile]) {
  final profileAvatar = profile?.avatarUrl;
  if (profileAvatar != null && profileAvatar.isNotEmpty) {
    return profileAvatar;
  }

  final metadata = user?.userMetadata as Map<String, dynamic>?;
  final avatar = metadata?['avatar_url'] as String?;
  final picture = metadata?['picture'] as String?;
  if (avatar != null && avatar.isNotEmpty) {
    return avatar;
  }
  if (picture != null && picture.isNotEmpty) {
    return picture;
  }
  return null;
}

String _greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning';
  }
  if (hour < 17) {
    return 'Good Afternoon';
  }
  return 'Good Evening';
}
