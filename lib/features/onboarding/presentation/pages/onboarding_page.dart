import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/preferences/preference_keys.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  static const Color _violet = Color(0xFF7C3AED);
  static const Color _deepPurple = Color(0xFF4C1D95);

  final PageController _pageController = PageController();
  late final AnimationController _iconAnimationController;
  late final Animation<double> _iconScaleAnimation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _iconScaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _iconAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<_OnboardingSlide> slides = <_OnboardingSlide>[
      _OnboardingSlide(
        icon: Icons.donut_large,
        title: l10n.onboardingPageOneTitle,
        subtitle: l10n.onboardingPageOneSubtitle,
      ),
      _OnboardingSlide(
        icon: Icons.menu,
        title: l10n.onboardingPageTwoTitle,
        subtitle: l10n.onboardingPageTwoSubtitle,
      ),
      _OnboardingSlide(
        icon: Icons.wifi_off,
        title: l10n.onboardingPageThreeTitle,
        subtitle: l10n.onboardingPageThreeSubtitle,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _deepPurple,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _deepPurple,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                _violet,
                _deepPurple,
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                  _iconAnimationController
                    ..reset()
                    ..forward();
                },
                itemBuilder: (BuildContext context, int index) {
                  return _OnboardingSlideView(
                    slide: slides[index],
                    active: index == _currentPage,
                    scaleAnimation: _iconScaleAnimation,
                  );
                },
              ),
              if (_currentPage < slides.length - 1)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 16),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.7),
                        ),
                        child: Text(l10n.onboardingSkipAction),
                      ),
                    ),
                  ),
                ),
              SafeArea(
                minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        _OnboardingDots(
                          count: slides.length,
                          currentIndex: _currentPage,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _OnboardingActionButton(
                            label: _currentPage == slides.length - 1
                                ? l10n.onboardingGetStartedAction
                                : l10n.onboardingNextAction,
                            filled: _currentPage == slides.length - 1,
                            onPressed: () => _handlePrimaryAction(
                              lastPageIndex: slides.length - 1,
                            ),
                          ),
                        ),
                      ],
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

  void _handlePrimaryAction({required int lastPageIndex}) {
    if (_currentPage >= lastPageIndex) {
      _completeOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    await sl<SharedPreferences>().setBool(
      onboardingCompletePreferenceKey,
      true,
    );
    if (!mounted) {
      return;
    }
    context.go('/');
  }
}

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({
    required this.slide,
    required this.active,
    required this.scaleAnimation,
  });

  final _OnboardingSlide slide;
  final bool active;
  final Animation<double> scaleAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Spacer(flex: 2),
        ScaleTransition(
          scale: active
              ? scaleAnimation
              : const AlwaysStoppedAnimation<double>(1),
          child: Icon(
            slide.icon,
            size: 120,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
              height: 1.45,
              letterSpacing: 0,
            ),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        count,
        (int index) {
          final bool active = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: active ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: active ? 1 : 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingActionButton extends StatelessWidget {
  const _OnboardingActionButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = filled
        ? FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _OnboardingPageState._violet,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          )
        : OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          );

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
