import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iprakriti_original/models/question_model.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/result_service.dart';
import 'onboarding/vata_screen.dart';
import 'onboarding/pitta_screen.dart';
import 'onboarding/kapha_screen.dart';
import 'questionnaire_screen.dart';
import 'result_screen.dart';

final dashboardResultsProvider =
    FutureProvider.autoDispose<List<PrakritiHistoryEntry>>((ref) async {
  final userId = ref.watch(authControllerProvider).session?.user.id;
  if (userId == null) {
    return [];
  }

  return ref.watch(resultServiceProvider).fetchResults(userId);
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
    this.initialIndex = 0,
  });

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
            child: IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
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
  const _HomeTab({
    required this.onOpenReports,
    required this.onOpenLearn,
  });

  final VoidCallback onOpenReports;
  final VoidCallback onOpenLearn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.session?.user;
    final fullName = _displayName(user);
    final avatarUrl = _avatarUrl(user);
    final greeting = _greetingForNow();
    final resultsAsync = ref.watch(dashboardResultsProvider);

    return resultsAsync.when(
      data: (results) => SingleChildScrollView(
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
            _AssessmentHero(
              onPressed: () => _openAssessment(context),
            ),
            if (results.isNotEmpty) ...[
              const SizedBox(height: 20),
              _LatestResultCard(
                entry: results.first,
                onTap: onOpenReports,
              ),
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
      error: (error, _) => Center(
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
      MaterialPageRoute<void>(
        builder: (_) => const QuestionnaireScreen(),
      ),
    );
  }

  static void _showRoutineDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
      data: (items) => SingleChildScrollView(
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
              'All Reports',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Track every saved assessment and compare your dosha trends over time.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5A5A5A),
                  ),
            ),
            const SizedBox(height: 22),
            if (items.isEmpty)
              _EmptyReportsCard(
                onStartAssessment: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const QuestionnaireScreen(),
                  ),
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ReportCard(item: item),
                ),
              ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
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
    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFEFB),
              Color(0xFFF3FAF1),
              Color(0xFFE8F4E3),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn Doshas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore Vata, Pitta, and Kapha to understand your prakruti better.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF5A5A5A),
                        ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF727272),
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1F7B33),
                            Color(0xFF16641F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2616641F),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(height: 52, text: 'Vata'),
                        Tab(height: 52, text: 'Pitta'),
                        Tab(height: 52, text: 'Kapha'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _LearnTabPage(child: VataScreen()),
                  _LearnTabPage(child: PittaScreen()),
                  _LearnTabPage(child: KaphaScreen()),
                ],
              ),
            ),
          ],
        ),
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
    final fullName = _displayName(user);
    final avatarUrl = _avatarUrl(user);
    final email = user?.email ?? 'No email available';

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
              final messenger = ScaffoldMessenger.of(context);
              try {
                final id = authState.session?.user.id;
                if (id == null) {
                  throw Exception('Please sign in before uploading an image.');
                }
                final url = await ref
                    .read(userServiceProvider)
                    .pickAndUploadProfileImage(id);
                if (url == null) {
                  return;
                }
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Profile image uploaded successfully.'),
                  ),
                );
              } catch (error) {
                messenger.showSnackBar(
                  SnackBar(content: Text(error.toString())),
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
                onTap: () => _showComingSoon(
                  context,
                  'Notification Preferences',
                ),
              ),
              _ProfileMenuItemData(
                title: 'Terms & Conditions',
                icon: Icons.settings_outlined,
                tint: const Color(0xFFEAF9E7),
                onTap: () => _showComingSoon(context, 'Terms & Conditions'),
              ),
              _ProfileMenuItemData(
                title: 'Privacy Policy',
                icon: Icons.shield_outlined,
                tint: const Color(0xFFEAF9E7),
                onTap: () => _showComingSoon(context, 'Privacy Policy'),
              ),
              _ProfileMenuItemData(
                title: 'About App',
                icon: Icons.info_outline_rounded,
                tint: const Color(0xFFEAF9E7),
                onTap: () => _showComingSoon(context, 'About App'),
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
                onTap: authState.isLoading
                    ? () {}
                    : ref.read(authControllerProvider.notifier).signOut,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title coming soon.')),
    );
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF545454),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ProfileAvatar(
          imageUrl: avatarUrl,
          fallbackLabel: fullName,
        ),
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
    final initials = fallbackLabel.isEmpty
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
        child: imageUrl == null
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
  const _AssessmentHero({
    required this.onPressed,
  });

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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF505050),
                ),
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
  const _LatestResultCard({
    required this.entry,
    required this.onTap,
  });

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
  const _ResultRing({
    required this.percent,
  });

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
            border: Border.all(
              color: const Color(0xFFF3F1EA),
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF707070),
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
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
  const _EmptyReportsCard({
    required this.onStartAssessment,
  });

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
  const _ReportCard({
    required this.item,
  });

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
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ResultScreen(result: result),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.finalPrakriti,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(item.createdAt),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  _DeleteReportButton(item: item),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ScoreChip(label: 'Vata', value: item.vataScore),
                  const SizedBox(width: 10),
                  _ScoreChip(label: 'Pitta', value: item.pittaScore),
                  const SizedBox(width: 10),
                  _ScoreChip(label: 'Kapha', value: item.kaphaScore),
                ],
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

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          '$label: $value',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
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
  const _ProfileMenuCard({
    required this.items,
  });

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
  const _ProfileMenuRow({
    required this.item,
  });

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
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

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

class _LearnTabPage extends StatelessWidget {
  const _LearnTabPage({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
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
  const _DeleteReportButton({
    required this.item,
  });

  final PrakritiHistoryEntry item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      },
      icon: const Icon(
        Icons.delete_outline_rounded,
        color: Color(0xFF9A9A9A),
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

String _displayName(dynamic user) {
  final fullName = user?.userMetadata?['full_name'] as String?;
  final name = user?.userMetadata?['name'] as String?;
  final emailPrefix = user?.email?.split('@').first;
  return fullName ?? name ?? emailPrefix ?? 'Wellness Seeker';
}

String? _avatarUrl(dynamic user) {
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
