import 'package:flutter/material.dart';

/// The font family name for the Noto Color Emoji (COLRv1) font,
/// as declared in pubspec.yaml.
const String notoColorEmojiFontFamily = 'NotoColorEmoji';

/// Returns a [TextStyle] configured to render emoji characters using the
/// bundled Noto Color Emoji (COLRv1) font.
///
/// This ensures uniform, cross-platform emoji rendering while leaving
/// standard text unaffected by the emoji font.
///
/// The [fontSize] defaults to 20. Pass any size appropriate for the context.
///
/// ## Why not fontFamilyFallback?
/// The Noto Color Emoji font includes basic Latin glyphs rendered in a
/// monospace style. Using it as a `fontFamilyFallback` causes regular text
/// to fall back to the emoji font's Latin glyphs, changing the appearance
/// of non-emoji text. Therefore, the emoji font must be applied directly
/// only to emoji-only text widgets via [EmojiText] or [emojiTextStyle].
///
/// ## Graceful Fallback
/// The Noto-COLRv1-emojicompat font includes multiple rendering tables
/// (COLRv1, sbix, CBDT/CBLC) for maximum compatibility. On platforms that
/// lack COLRv1 support, the font automatically falls back to sbix or
/// bitmap tables. If the font fails to load entirely, Flutter's default
/// font fallback chain will use the system emoji font.
TextStyle emojiTextStyle({double fontSize = 20, Color? color}) {
  return TextStyle(fontFamily: notoColorEmojiFontFamily, fontSize: fontSize, color: color);
}

/// A convenience widget that displays emoji text using the bundled
/// Noto Color Emoji font.
///
/// Use this instead of `Text(emoji)` for any widget that displays
/// only emoji characters to ensure consistent cross-platform rendering.
///
/// Regular text remains completely unaffected because the emoji font is
/// applied only to dedicated emoji widgets, not as a global fallback.
///
/// Example:
/// ```dart
/// EmojiText('🎉', fontSize: 28)
/// ```
class EmojiText extends StatelessWidget {
  final String emoji;
  final double fontSize;
  final Color? color;

  const EmojiText(this.emoji, {super.key, this.fontSize = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: emojiTextStyle(fontSize: fontSize, color: color),
    );
  }
}
