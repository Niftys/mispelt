import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final bool showSubtitle;
  final Color? color;
  final Color? subtitleColor;
  final String? imagePath; // Path to PNG file in assets
  final bool useImage; // Whether to use image or text logo

  const AppLogo({
    super.key,
    this.size,
    this.showSubtitle = true,
    this.color,
    this.subtitleColor,
    this.imagePath,
    this.useImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoColor = color ?? const Color(0xFF5D4E37);
    final subtitleTextColor = subtitleColor ?? const Color(0xFF8B7355);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo - Image or Text
        useImage && imagePath != null
            ? _buildImageLogo()
            : _buildTextLogo(theme, logoColor),

        // Dictionary-style subtitle
        if (showSubtitle) ...[
          const SizedBox(height: GameConstants.spacingXs),
          Text(
            '"to spell (a word or words) wrongly"',
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtitleTextColor,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.3,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildImageLogo() {
    return Image.asset(
      imagePath!,
      width: size ?? 200,
      height: size != null ? size! * 0.5 : 100,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTextLogo(ThemeData theme, Color logoColor) {
    return Text(
      'Mispelt',
      style: theme.textTheme.headlineLarge?.copyWith(
        color: logoColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        fontSize: size != null ? size! * 0.6 : 32,
        shadows: [
          Shadow(
            color: logoColor.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

// Alternative logo widget for smaller spaces
class AppLogoCompact extends StatelessWidget {
  final double? size;
  final String? imagePath;
  final bool useImage;
  final Color? color;

  const AppLogoCompact({
    super.key,
    this.size,
    this.imagePath,
    this.useImage = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoColor = color ?? const Color(0xFF5D4E37);

    return useImage && imagePath != null
        ? _buildImageLogo()
        : _buildTextLogo(theme, logoColor);
  }

  Widget _buildImageLogo() {
    return Image.asset(
      imagePath!,
      width: size ?? 120,
      height: size != null ? size! * 0.5 : 60,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTextLogo(ThemeData theme, Color logoColor) {
    return Text(
      'Mispelt',
      style: theme.textTheme.titleLarge?.copyWith(
        color: logoColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        fontSize: size != null ? size! * 0.4 : 20,
        shadows: [
          Shadow(
            color: logoColor.withOpacity(0.2),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
