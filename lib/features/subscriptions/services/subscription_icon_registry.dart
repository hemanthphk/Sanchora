
enum LogoSourceType { network, local, none }

class SubscriptionLogoData {
  final String path;
  final LogoSourceType type;

  const SubscriptionLogoData({required this.path, required this.type});
}

/// Centralized registry for mapping subscription brand identifiers, preset keys,
/// or service names to their corresponding asset image paths.
class SubscriptionIconRegistry {
  SubscriptionIconRegistry._();

  /// Default fallback icon path for unrecognized subscriptions.
  static const String defaultIconPath = 'assets/images/default_logo.png';

  /// Map of normalized identifiers/keys to asset image paths.
  static const Map<String, String> _registry = {
    // Entertainment / Streaming
    'netflix': 'https://logo.clearbit.com/netflix.com',
    'spotify': 'https://logo.clearbit.com/spotify.com',
    'youtube': 'https://logo.clearbit.com/youtube.com',
    'youtube_premium': 'https://logo.clearbit.com/youtube.com',
    'youtube_music': 'https://logo.clearbit.com/music.youtube.com',
    'amazon': 'https://logo.clearbit.com/amazon.com',
    'amazon_prime': 'https://logo.clearbit.com/amazon.com',
    'amazon_prime_video': 'https://logo.clearbit.com/primevideo.com',
    'prime_video': 'https://logo.clearbit.com/primevideo.com',
    'hotstar': 'https://logo.clearbit.com/hotstar.com',
    'disney_hotstar': 'https://logo.clearbit.com/hotstar.com',
    'jiohotstar': 'https://logo.clearbit.com/jiohotstar.com',
    'apple_tv': 'https://logo.clearbit.com/tv.apple.com',
    'apple_tv_plus': 'https://logo.clearbit.com/tv.apple.com',
    'apple_music': 'https://logo.clearbit.com/music.apple.com',

    // AI & Tech
    'chatgpt': 'https://logo.clearbit.com/chatgpt.com',
    'chatgpt_plus': 'https://logo.clearbit.com/chatgpt.com',
    'openai': 'https://logo.clearbit.com/openai.com',
    'gemini': 'https://logo.clearbit.com/gemini.google.com',
    'gemini_advanced': 'https://logo.clearbit.com/gemini.google.com',
    'claude': 'https://logo.clearbit.com/claude.ai',
    'claude_pro': 'https://logo.clearbit.com/claude.ai',
    'notion_ai': 'https://logo.clearbit.com/notion.so',

    // Productivity & Tools
    'google': 'https://logo.clearbit.com/google.com',
    'google_one': 'https://logo.clearbit.com/one.google.com',
    'microsoft': 'https://logo.clearbit.com/microsoft.com',
    'microsoft_365': 'https://logo.clearbit.com/microsoft365.com',
    'office_365': 'https://logo.clearbit.com/office.com',
    'adobe': 'https://logo.clearbit.com/adobe.com',
    'adobe_creative_cloud': 'https://logo.clearbit.com/adobe.com',
    'github': 'https://logo.clearbit.com/github.com',
    'github_pro': 'https://logo.clearbit.com/github.com',
    'canva': 'https://logo.clearbit.com/canva.com',
    'canva_pro': 'https://logo.clearbit.com/canva.com',
    'figma': 'https://logo.clearbit.com/figma.com',
    'figma_professional': 'https://logo.clearbit.com/figma.com',
    'notion': 'https://logo.clearbit.com/notion.so',
    'zoom': 'https://logo.clearbit.com/zoom.us',
    'zoom_pro': 'https://logo.clearbit.com/zoom.us',

    // Generic fallback key
    'default': defaultIconPath,
  };

  /// Resolves any subscription key, name, or URL to the corresponding asset image path.
  /// If [identifier] is already a valid asset path, it is returned directly.
  /// Otherwise, it performs normalized lookup and keyword matching.
  static SubscriptionLogoData getIcon(String? identifier) {
    if (identifier == null || identifier.trim().isEmpty) {
      return const SubscriptionLogoData(path: '', type: LogoSourceType.none);
    }
    final clean = identifier.trim();

    // If it's already an HTTP URL (from legacy data)
    if (clean.startsWith('http')) {
      return SubscriptionLogoData(path: clean, type: LogoSourceType.network);
    }

    // If it's already a local asset path
    if (clean.startsWith('assets/')) {
      return SubscriptionLogoData(path: clean, type: LogoSourceType.local);
    }

    String? matchedPath;

    // Direct lookup
    if (_registry.containsKey(clean.toLowerCase())) {
      matchedPath = _registry[clean.toLowerCase()];
    } else {
      // Convert to lowercase and replace special chars/spaces with underscores for lookup
      final normalized = clean
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');

      if (_registry.containsKey(normalized)) {
        matchedPath = _registry[normalized];
      } else {
        // Keyword matching fallback
        for (final entry in _registry.entries) {
          if (entry.key == 'default') continue;
          if (normalized == entry.key ||
              normalized.contains(entry.key) ||
              entry.key.contains(normalized)) {
            matchedPath = entry.value;
            break;
          }
        }
      }
    }

    if (matchedPath != null) {
      if (matchedPath.startsWith('http')) {
        return SubscriptionLogoData(path: matchedPath, type: LogoSourceType.network);
      } else {
        return SubscriptionLogoData(path: matchedPath, type: LogoSourceType.local);
      }
    }

    return const SubscriptionLogoData(path: '', type: LogoSourceType.none);
  }
}
