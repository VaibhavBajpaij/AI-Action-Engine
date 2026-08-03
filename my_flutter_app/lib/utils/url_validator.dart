class UrlValidationResult {
  final String? canonicalUrl;
  final String? platform;
  final String? error;

  const UrlValidationResult.success(this.canonicalUrl, this.platform) : error = null;
  const UrlValidationResult.error(this.error) : canonicalUrl = null, platform = null;

  bool get isSuccess => error == null;
}

class UrlValidator {
  static const _hostMappings = <String, String>{
    'youtube.com': 'youtube',
    'youtu.be': 'youtube',
    'm.youtube.com': 'youtube',
    'instagram.com': 'instagram',
    'www.instagram.com': 'instagram',
    'linkedin.com': 'linkedin',
    'www.linkedin.com': 'linkedin',
    'reddit.com': 'reddit',
    'redd.it': 'reddit',
    'old.reddit.com': 'reddit',

    'facebook.com': 'facebook',
    'www.facebook.com': 'facebook',
    'fb.watch': 'facebook',
  };

  static const _trackingParams = {
    'igsh',
    'si',
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'fbclid',
  };

  static UrlValidationResult validate(String urlText) {
    // Extract first URL if it's mixed with text
    final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(urlText);
    if (urlMatch == null) {
      return const UrlValidationResult.error('Please enter a valid URL.');
    }
    
    final uri = Uri.tryParse(urlMatch.group(0)!);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return const UrlValidationResult.error('Please enter a valid URL.');
    }

    final host = uri.host.toLowerCase();
    String? platform;

    for (final entry in _hostMappings.entries) {
      if (host == entry.key || host.endsWith('.${entry.key}')) {
        platform = entry.value;
        break;
      }
    }

    if (platform == null) {
      return const UrlValidationResult.error("Reelcraft doesn't support links from this site yet.");
    }

    // Strip tracking parameters
    final Map<String, dynamic> newQueryParams = Map.from(uri.queryParameters);
    newQueryParams.removeWhere((key, _) => _trackingParams.contains(key));

    final canonicalUri = uri.replace(
      queryParameters: newQueryParams.isEmpty ? null : newQueryParams,
    );

    return UrlValidationResult.success(canonicalUri.toString(), platform);
  }
}
