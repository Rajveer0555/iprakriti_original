import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DocumentScreen(title: 'About App', child: _AboutAppContent());
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DocumentScreen(
      title: 'Privacy Policy',
      child: _PrivacyPolicyContent(),
    );
  }
}

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DocumentScreen(
      title: 'Terms & Condition',
      child: _TermsConditionsContent(),
    );
  }
}

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  static const _dailyHealthKey = 'notification_daily_health_tip';
  static const _reassessmentKey = 'notification_reassessment_reminder';
  static const _productUpdatesKey = 'notification_product_updates';

  bool _dailyHealthTips = true;
  bool _reassessmentReminder = true;
  bool _productUpdates = true;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 30, 26, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SettingsHeader(title: 'Notification Preferences'),
              const SizedBox(height: 45),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3E5E1)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    _isLoaded
                        ? Column(
                          children: [
                            _NotificationPreferenceRow(
                              icon: Icons.notifications_none_rounded,
                              title: 'Daily Health Tip Reminder',
                              subtitle: 'Receive wellness tips everyday',
                              value: _dailyHealthTips,
                              onChanged:
                                  (value) => _savePreference(
                                    key: _dailyHealthKey,
                                    value: value,
                                    update: () => _dailyHealthTips = value,
                                  ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE5E5E5)),
                            _NotificationPreferenceRow(
                              icon: Icons.calendar_month_outlined,
                              title: 'Reassessment Reminder',
                              subtitle: 'Task change in your Prakruti',
                              value: _reassessmentReminder,
                              onChanged:
                                  (value) => _savePreference(
                                    key: _reassessmentKey,
                                    value: value,
                                    update: () => _reassessmentReminder = value,
                                  ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE5E5E5)),
                            _NotificationPreferenceRow(
                              icon: Icons.campaign_rounded,
                              title: 'Product Update & News',
                              subtitle: 'Get notified about new features',
                              value: _productUpdates,
                              onChanged:
                                  (value) => _savePreference(
                                    key: _productUpdatesKey,
                                    value: value,
                                    update: () => _productUpdates = value,
                                  ),
                            ),
                          ],
                        )
                        : const SizedBox(
                          height: 226,
                          child: Center(child: CircularProgressIndicator()),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _dailyHealthTips = prefs.getBool(_dailyHealthKey) ?? true;
      _reassessmentReminder = prefs.getBool(_reassessmentKey) ?? true;
      _productUpdates = prefs.getBool(_productUpdatesKey) ?? true;
      _isLoaded = true;
    });
  }

  Future<void> _savePreference({
    required String key,
    required bool value,
    required VoidCallback update,
  }) async {
    setState(update);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}

class _DocumentScreen extends StatelessWidget {
  const _DocumentScreen({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 30, 26, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsHeader(title: title),
              const SizedBox(height: 45),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(21, 25, 21, 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFF1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8DC48B)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).pop(),
          child: const SizedBox(
            width: 28,
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 21,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutAppContent extends StatelessWidget {
  const _AboutAppContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AboutSection(
          title: 'Who We Are',
          icon: Icons.eco_rounded,
          body:
              'IPrakriti is an AI-powered Ayurvedic wellness platform designed to help you understand your unique body constitution — known in Ayurveda as Prakruti.\nWe combine traditional Ayurvedic principles with modern technology to deliver personalized wellness insights in a simple, accessible format.',
        ),
        _AboutSection(
          title: 'Our Mission',
          icon: Icons.health_and_safety_rounded,
          body:
              'Our mission is to make ancient Ayurvedic wisdom accessible through intelligent digital tools.\nWe aim to:\n  • Help individuals understand their natural body type\n  • Promote preventive wellness\n  • Encourage balanced lifestyle habits\n  • Provide practical, personalized recommendations\nWe believe true wellness begins with self-awareness.',
        ),
        _AboutSection(
          title: 'How It Works',
          icon: Icons.biotech_rounded,
          body:
              'IPrakriti uses:\n  • AI-based facial analysis\n  • Guided lifestyle questionnaires\n  • Dosha evaluation algorithms\nBased on your inputs, we determine your dominant dosha (Vata, Pitta, or Kapha) and provide customized lifestyle, diet, and wellness recommendations.',
        ),
        _AboutSection(
          title: 'Our Philosophy',
          icon: Icons.spa_rounded,
          body:
              'Ayurveda teaches that every individual is unique.\nRather than offering generic health advice, IPrakriti focuses on:\n  • Personalization\n  • Balance\n  • Preventive wellness\n  • Sustainable habits\nWe do not replace medical professionals — we complement your wellness journey.',
        ),
        _AboutSection(
          title: 'Privacy & Trust',
          icon: Icons.lock_open_rounded,
          body:
              'Your data privacy is important to us.\n  • Facial scans are processed securely\n  • Personal data is protected\n  • We do not sell your information\nOur goal is to build a trustworthy wellness companion.',
        ),
        _AboutSection(
          title: 'Our Vision',
          icon: Icons.rocket_launch_rounded,
          body:
              'We envision IPrakriti becoming a holistic wellness assistant that helps individuals:\n  • Track their wellness journey\n  • Maintain dosha balance\n  • Develop mindful daily routines\n  • Make informed lifestyle choices\nBridging ancient wisdom with modern innovation.',
        ),
        _AboutSection(
          title: 'Contact Us',
          icon: Icons.mark_email_unread_rounded,
          body:
              'Have questions or feedback?\nEmail: iprakriti@gmail.com\nApp: IPrakriti',
          bottomSpacing: 0,
        ),
      ],
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentText('Effective Date: [Add Date]', isLead: true),
        SizedBox(height: 18),
        _DocumentText('App Name :- IPrakriti', isLead: true),
        _Rule(),
        _DocumentSection(
          title: '1. Introduction',
          body:
              'Welcome to IPrakriti.\nYour privacy is important to us. This Privacy Policy explains how we collect, use, store, and protect your information when you use the IPrakriti mobile application ("App").\nBy using the App, you agree to the terms outlined in this Privacy Policy.',
        ),
        _DocumentSection(
          title: '2. Information We Collect',
          body:
              'We collect information to provide personalized Ayurvedic assessments and improve user experience.\n\nA. Personal Information\nWhen you create an account, we may collect:\n  • Full name\n  • Email address\n  • Age\n  • Gender\n  • Height and weight\n\nB. Facial Scan Data\nWhen you use the face scan feature:\n  • Your facial image is processed for Prakruti analysis.\n  • The image is analyzed by AI algorithms.\n  • Images are not permanently stored unless explicitly stated.\n  • We do not use facial data for identification or surveillance purposes.\n\nC. Assessment Data\nWe collect:\n  • Questionnaire responses\n  • Dosha assessment results\n  • Recommendation history\nThis data helps generate personalized wellness guidance.\n\nD. Device Information\nWe may collect limited technical information such as:\n  • Device type\n  • App version\n  • Operating system\n  • Crash logs\nThis helps us improve performance.',
        ),
        _DocumentSection(
          title: '3. How We Use Your Information',
          body:
              'We use collected data to:\n  • Generate Prakruti assessment results\n  • Provide personalized recommendations\n  • Improve app functionality\n  • Send reminders (if enabled)\n  • Enhance user experience\nWe do not sell your personal information.',
        ),
        _DocumentSection(
          title: '4. Data Storage & Security',
          body:
              'We implement reasonable security measures to protect your data.\n  • Secure authentication methods\n  • Encrypted data transmission\n  • Restricted access to stored data\nHowever, no digital system is completely secure.',
        ),
        _DocumentSection(
          title: '5. Data Sharing',
          body:
              'We do not share your personal data with third parties except:\n  • When required by law\n  • For secure backend processing (if applicable)\n  • With your explicit consent',
        ),
        _DocumentSection(
          title: '6. Notifications & Communication',
          body:
              'If you enable reminders, we may send:\n  • Daily wellness tips\n  • Reassessment reminders\n  • Product updates\nYou can disable notifications at any time from Settings.',
        ),
        _DocumentSection(
          title: '7. Data Retention',
          body:
              'We retain your assessment history for:\n  • Viewing past reports\n  • Tracking progress\nYou may request deletion of your account and associated data.',
        ),
        _DocumentSection(
          title: "8. Children's Privacy",
          body:
              'IPrakriti is not intended for children under 13 years of age. We do not knowingly collect data from minors.',
        ),
        _DocumentSection(
          title: '9. User Rights',
          body:
              'You have the right to:\n  • Access your data\n  • Update your information\n  • Delete your account\n  • Withdraw consent\nContact us for any data-related requests.',
        ),
        _DocumentSection(
          title: '10. Changes to This Policy',
          body:
              'We may update this Privacy Policy periodically.\nContinued use of the App after updates means you accept the revised policy.',
          bottomRule: false,
        ),
      ],
    );
  }
}

class _TermsConditionsContent extends StatelessWidget {
  const _TermsConditionsContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentText('Effective Date: [Add Date]', isLead: true),
        SizedBox(height: 18),
        _DocumentText('App Name :- IPrakriti', isLead: true),
        _Rule(),
        _DocumentSection(
          title: '1. Acceptance of Terms',
          body:
              'By accessing or using the IPrakriti mobile application ("App"), you agree to be bound by these Terms & Conditions. If you do not agree, please do not use the App.',
        ),
        _DocumentSection(
          title: '2. About IPrakriti',
          body:
              'IPrakriti is an AI-based Ayurvedic wellness application designed to provide:\n  • Prakruti (Vata, Pitta, Kapha) assessment\n  • Lifestyle insights\n  • Dietary recommendations\n  • Educational Ayurvedic content\nThe App is intended for informational and wellness purposes only.',
        ),
        _DocumentSection(
          title: '3. Not Medical Advice',
          body:
              'IPrakriti does not provide medical diagnosis, treatment, or professional healthcare services.\n  • The results generated are based on algorithmic analysis.\n  • Recommendations are general wellness suggestions.\n  • Always consult a qualified medical professional before making health decisions.\nThe App should not be used as a substitute for professional medical advice.',
        ),
        _DocumentSection(
          title: '4. User Responsibilities',
          body:
              'By using the App, you agree:\n  • To provide accurate information during assessments.\n  • Not to misuse or attempt to manipulate results.\n  • Not to reverse-engineer or tamper with the AI system.\nYou are responsible for maintaining the confidentiality of your account credentials.',
        ),
        _DocumentSection(
          title: '5. Data & Privacy',
          body:
              'IPrakriti processes user data in accordance with its Privacy Policy.\n  • Facial scans are processed securely.\n  • Personal data is used only for assessment and app functionality.\n  • We do not sell personal data to third parties.\nPlease review the Privacy Policy for full details.',
        ),
        _DocumentSection(
          title: '6. Intellectual Property',
          body:
              'All content within the App, including:\n  • Design\n  • Text\n  • Graphics\n  • Logos\n  • Algorithms\nis the property of IPrakriti and may not be copied, reproduced, or distributed without permission.',
        ),
        _DocumentSection(
          title: '7. Limitation of Liability',
          body:
              'IPrakriti shall not be liable for:\n  • Any health decisions made based on app results\n  • Inaccuracies in AI-generated assessments\n  • Any indirect or incidental damages\nUse of the App is at your own risk.',
        ),
        _DocumentSection(
          title: '8. Modifications to the App',
          body:
              'We reserve the right to:\n  • Modify features\n  • Update recommendations\n  • Change or discontinue services\nat any time without prior notice.',
        ),
        _DocumentSection(
          title: '9. Termination',
          body:
              'We may suspend or terminate access if:\n  • Terms are violated\n  • Misuse or abuse is detected',
        ),
        _DocumentSection(
          title: '10. Changes to Terms',
          body:
              'We may update these Terms & Conditions periodically. Continued use of the App constitutes acceptance of the updated terms.',
          bottomRule: false,
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.title,
    required this.icon,
    required this.body,
    this.bottomSpacing = 29,
  });

  final String title;
  final IconData icon;
  final String body;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF61BE38)),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DocumentText(body),
        ],
      ),
    );
  }
}

class _DocumentSection extends StatelessWidget {
  const _DocumentSection({
    required this.title,
    required this.body,
    this.bottomRule = true,
  });

  final String title;
  final String body;
  final bool bottomRule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentText(title, isSectionTitle: true),
        const SizedBox(height: 17),
        _DocumentText(body),
        if (bottomRule) const _Rule(),
      ],
    );
  }
}

class _DocumentText extends StatelessWidget {
  const _DocumentText(
    this.text, {
    this.isLead = false,
    this.isSectionTitle = false,
  });

  final String text;
  final bool isLead;
  final bool isSectionTitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: isSectionTitle ? 14 : 12,
        height: 1.08,
        fontWeight:
            isLead || isSectionTitle ? FontWeight.w700 : FontWeight.w500,
        color: Colors.black,
        letterSpacing: 0,
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 23),
      child: Divider(height: 1, color: Color(0xFFB7C9B6)),
    );
  }
}

class _NotificationPreferenceRow extends StatelessWidget {
  const _NotificationPreferenceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF9E7),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF75C765), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      height: 1.15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      height: 1,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF1E6B2B),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFBFC8BD),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
