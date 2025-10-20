import 'package:flutter/material.dart';
import 'package:irondex/widgets/auth/oauth_icons.dart';

class OAuthLoginButtons extends StatelessWidget {
  const OAuthLoginButtons({
    super.key,
    this.onKakao,
    this.onNaver,
    this.onGoogle,
  });

  final Future<void> Function()? onKakao;
  final Future<void> Function()? onNaver;
  final Future<void> Function()? onGoogle;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OAuthButton(
          backgroundColor: const Color(0xFFFEE500),
          foregroundColor: Colors.black,
          icon: const KakaoIcon(color: Colors.black),
          brandName: 'Kakao',
          onPressed: onKakao,
        ),
        gap,
        _OAuthButton(
          backgroundColor: const Color(0xFF03C75A),
          foregroundColor: Colors.white,
          icon: const NaverIcon(color: Colors.white),
          brandName: 'Naver',
          onPressed: onNaver,
        ),
        gap,
        _OAuthButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          icon: const GoogleIcon(),
          border: const BorderSide(color: Color(0xFFD1D5DB), width: 2),
          brandName: 'Google',
          onPressed: onGoogle,
        ),
      ],
    );
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.brandName,
    this.onPressed,
    this.border,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final String brandName;
  final Future<void> Function()? onPressed;
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final themeStyle = Theme.of(context).textTheme.titleMedium;
    final baseStyle = (themeStyle ?? const TextStyle()).copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w500,
    );
    final brandStyle = baseStyle.copyWith(fontWeight: FontWeight.w700);

    return Material(
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: border ?? BorderSide.none,
      ),
      child: InkWell(
        onTap: onPressed == null ? null : () => onPressed!(),
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: 'Sign in with ',
                    style: baseStyle,
                    children: [TextSpan(text: brandName, style: brandStyle)],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
