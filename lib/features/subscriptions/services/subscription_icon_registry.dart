
/// Centralized registry for mapping subscription brand identifiers, preset keys,
/// or service names to their corresponding asset image paths.
class SubscriptionIconRegistry {
  SubscriptionIconRegistry._();

  /// Default fallback icon path for unrecognized subscriptions.
  static const String defaultIconPath = 'assets/images/default_logo.png';

  /// Map of normalized identifiers/keys to asset image paths.
  static const Map<String, String> _registry = {
    // Entertainment / Streaming
    'netflix': 'assets/images/netflix_logo.png',
    'spotify': 'assets/images/spotify_logo.png',
    'youtube': 'assets/images/youtube_logo.png',
    'youtube_premium': 'assets/images/youtube_logo.png',
    'youtube_music': 'assets/images/youtube_music_logo.png',
    'amazon': 'assets/images/amazon_logo.png',
    'amazon_prime': 'assets/images/amazon_logo.png',
    'amazon_prime_video': 'assets/images/amazon_logo.png',
    'prime_video': 'assets/images/amazon_logo.png',
    'hotstar': 'assets/images/hotstar_logo.png',
    'disney_hotstar': 'assets/images/hotstar_logo.png',
    'jiohotstar': 'assets/images/jiohotstar_logo.png',
    'apple_tv': 'assets/images/apple_tv_logo.png',
    'apple_tv_plus': 'assets/images/apple_tv_logo.png',
    'apple_music': 'assets/images/apple_music_logo.png',

    // AI & Tech
    'chatgpt': 'assets/images/chatgpt_logo.png',
    'chatgpt_plus': 'assets/images/chatgpt_logo.png',
    'openai': 'assets/images/chatgpt_logo.png',
    'gemini': 'assets/images/gemini_logo.png',
    'gemini_advanced': 'assets/images/gemini_logo.png',
    'claude': 'assets/images/claude_logo.png',
    'claude_pro': 'assets/images/claude_logo.png',
    'notion_ai': 'assets/images/notion_logo.png',

    // Productivity & Tools
    'google': 'assets/images/google_logo.png',
    'google_one': 'assets/images/google_logo.png',
    'microsoft': 'assets/images/microsoft_logo.png',
    'microsoft_365': 'assets/images/microsoft_logo.png',
    'office_365': 'assets/images/microsoft_logo.png',
    'adobe': 'assets/images/adobe_logo.png',
    'adobe_creative_cloud': 'assets/images/adobe_logo.png',
    'github': 'assets/images/github_logo.png',
    'github_pro': 'assets/images/github_logo.png',
    'canva': 'assets/images/canva_logo.png',
    'canva_pro': 'assets/images/canva_logo.png',
    'figma': 'assets/images/figma_logo.png',
    'figma_professional': 'assets/images/figma_logo.png',
    'notion': 'assets/images/notion_logo.png',
    'zoom': 'assets/images/zoom_logo.png',
    'zoom_pro': 'assets/images/zoom_logo.png',

    // Generic fallback key
    'default': defaultIconPath,
  };

  /// Resolves any subscription key, name, or URL to the corresponding asset image path.
  /// If [identifier] is already a valid asset path, it is returned directly.
  /// Otherwise, it performs normalized lookup and keyword matching, returning [defaultIconPath] if no match is found.
  static String getIconUrl(String? identifier) {
    if (identifier == null || identifier.trim().isEmpty) {
      return defaultIconPath;
    }
    final clean = identifier.trim();

    // If it's already an asset path, return it directly.
    if (clean.startsWith('assets/')) {
      return clean;
    }

    // Direct lookup
    if (_registry.containsKey(clean.toLowerCase())) {
      return _registry[clean.toLowerCase()]!;
    }

    // Convert to lowercase and replace special chars/spaces with underscores for lookup
    final normalized = clean
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (_registry.containsKey(normalized)) {
      return _registry[normalized]!;
    }

    // Keyword matching fallback
    for (final entry in _registry.entries) {
      if (entry.key == 'default') continue;
      if (normalized == entry.key ||
          normalized.contains(entry.key) ||
          entry.key.contains(normalized)) {
        return entry.value;
      }
    }

    return defaultIconPath;
  }
}
