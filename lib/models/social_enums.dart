// File: lib/models/social_enums.dart
// Purpose: Type-safe enum representing social platforms (facebook, instagram, other).

enum SocialPlatform {
  facebook,
  instagram,
  other;

  String get dbValue {
    switch (this) {
      case SocialPlatform.facebook:
        return 'facebook';
      case SocialPlatform.instagram:
        return 'instagram';
      case SocialPlatform.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.other:
        return 'Other';
    }
  }

  static SocialPlatform fromDbValue(String? value) {
    if (value == null || value.trim().isEmpty) return SocialPlatform.other;
    switch (value.toLowerCase().trim()) {
      case 'facebook':
        return SocialPlatform.facebook;
      case 'instagram':
      case 'insta':
        return SocialPlatform.instagram;
      default:
        return SocialPlatform.other;
    }
  }
}
