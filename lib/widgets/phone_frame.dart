import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/greenleaf_theme.dart';

/// Wraps the app in a centred 390x844 phone frame with rounded corners and a
/// top notch on desktop/laptop browsers, and renders full screen on real phones.
class PhoneFrameWrapper extends StatelessWidget {
  const PhoneFrameWrapper({
    super.key,
    required this.child,
  });

  static const double phoneWidth = 390;
  static const double phoneHeight = 844;
  static const double desktopBreakpoint = 600;

  final Widget child;

  bool _shouldUsePhoneFrame(BuildContext context, BoxConstraints constraints) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isNativePhone = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android) &&
        shortestSide < desktopBreakpoint;
    if (isNativePhone) return false;
    return constraints.maxWidth >= desktopBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_shouldUsePhoneFrame(context, constraints)) {
          return child;
        }

        final mediaQuery = MediaQuery.of(context);

        return Container(
          color: GreenleafColors.desktopBackdrop,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _PhoneChassis(
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  size: const Size(phoneWidth, phoneHeight),
                  padding: const EdgeInsets.only(top: 44, bottom: 20),
                  viewPadding: const EdgeInsets.only(top: 44, bottom: 20),
                  viewInsets: EdgeInsets.zero,
                ),
                child: SizedBox(
                  width: phoneWidth,
                  height: phoneHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(child: child),
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _PhoneStatusBarAndNotch(),
                      ),
                      const Positioned(
                        bottom: 7,
                        left: 0,
                        right: 0,
                        child: _HomeIndicator(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhoneChassis extends StatelessWidget {
  const _PhoneChassis({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: GreenleafColors.phoneBezel,
        borderRadius: BorderRadius.circular(54),
        border: Border.all(color: const Color(0xFF3A443D), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33121A14),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color(0x14121A14),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42),
        child: child,
      ),
    );
  }
}

class _PhoneStatusBarAndNotch extends StatelessWidget {
  const _PhoneStatusBarAndNotch();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Top hardware notch.
            Container(
              width: 146,
              height: 28,
              decoration: const BoxDecoration(
                color: GreenleafColors.phoneBezel,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF364039),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF283747),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3E4B42),
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Left time & right status icons.
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '9:41',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GreenleafColors.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.signal_cellular_alt_rounded,
                          size: 14,
                          color: GreenleafColors.textPrimary,
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.wifi_rounded,
                          size: 14,
                          color: GreenleafColors.textPrimary,
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.battery_full_rounded,
                          size: 16,
                          color: GreenleafColors.textPrimary,
                        ),
                      ],
                    ),
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

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 120,
          height: 4.5,
          decoration: BoxDecoration(
            color: const Color(0x441C2B1E),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
