import 'package:flutter/material.dart';
import 'package:mahrah_blood_bank/config/theme.dart';
import 'package:mahrah_blood_bank/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mahrah_blood_bank/utils/constants.dart';

/// شاشة التعريف بالتطبيق (Onboarding)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.favorite,
      title: 'وفر حياة.. تبرع بالدم',
      description:
          'كن بطلاً وساهم في إنقاذ حياة إنسان محتاج. تبرعك بالدم قد يكون سبباً في إنقاذ حياة',
      color: AppTheme.primaryRed,
    ),
    OnboardingPage(
      icon: Icons.search,
      title: 'احصل على متبرع في دقائق',
      description:
          'ابحث عن متبرعين بالدم في منطقتك بسهولة وسرعة. نوفر لك قاعدة بيانات شاملة للمتبرعين',
      color: AppTheme.secondaryGreen,
    ),
    OnboardingPage(
      icon: Icons.volunteer_activism,
      title: 'خدمة مجانية لأهل المهرة',
      description:
          'خدمة مجانية بالكامل لربط المتبرعين بالمحتاجين في محافظة المهرة. معاً نبني مجتمعاً أفضل',
      color: AppTheme.primaryRed,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.hasSeenOnboarding, true);

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/account-type');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // زر التخطي
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  'تخطي',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // الصفحات
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // المؤشرات
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),
            const SizedBox(height: 32),

            // زر التالي أو ابدأ الآن
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              child: CustomButton(
                text:
                    _currentPage == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: _currentPage == _pages.length - 1
                    ? Icons.check
                    : Icons.arrow_back,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الأيقونة
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),

          // العنوان
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // الوصف
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryRed : AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// نموذج صفحة التعريف
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
