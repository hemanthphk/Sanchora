enum AccountProvider {
  google,
  apple,
  facebook,
  github,
  microsoft,
  phone,
}

extension AccountProviderExtension on AccountProvider {
  String get displayName {
    switch (this) {
      case AccountProvider.google:
        return 'Google';
      case AccountProvider.apple:
        return 'Apple';
      case AccountProvider.facebook:
        return 'Facebook';
      case AccountProvider.github:
        return 'GitHub';
      case AccountProvider.microsoft:
        return 'Microsoft';
      case AccountProvider.phone:
        return 'Phone Number';
    }
  }

  String get iconAsset {
    // In a real app, these would map to actual SVG/PNG assets.
    // For now, we will map them to icon data strings or just use IconData in the UI directly.
    return name;
  }
}

class LinkedAccount {
  final AccountProvider provider;
  final bool isConnected;
  final bool isPrimary;
  final String? identifier; // email or phone number

  const LinkedAccount({
    required this.provider,
    required this.isConnected,
    this.isPrimary = false,
    this.identifier,
  });

  LinkedAccount copyWith({
    AccountProvider? provider,
    bool? isConnected,
    bool? isPrimary,
    String? identifier,
  }) {
    return LinkedAccount(
      provider: provider ?? this.provider,
      isConnected: isConnected ?? this.isConnected,
      isPrimary: isPrimary ?? this.isPrimary,
      identifier: identifier ?? this.identifier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'isConnected': isConnected,
      'isPrimary': isPrimary,
      'identifier': identifier,
    };
  }

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      provider: AccountProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => AccountProvider.google,
      ),
      isConnected: json['isConnected'] as bool? ?? false,
      isPrimary: json['isPrimary'] as bool? ?? false,
      identifier: json['identifier'] as String?,
    );
  }
}
