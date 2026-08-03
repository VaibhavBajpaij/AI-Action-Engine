import 'package:flutter_test/flutter_test.dart';
import 'package:reelcraft/utils/url_validator.dart';

void main() {
  group('UrlValidator', () {
    test('youtube.com, youtu.be, m.youtube.com resolve to youtube', () {
      expect(UrlValidator.validate('https://youtube.com/watch?v=123').platform, 'youtube');
      expect(UrlValidator.validate('https://youtu.be/123').platform, 'youtube');
      expect(UrlValidator.validate('https://m.youtube.com/watch?v=123').platform, 'youtube');
    });

    test('instagram.com, www.instagram.com resolve to instagram', () {
      expect(UrlValidator.validate('https://instagram.com/reel/123').platform, 'instagram');
      expect(UrlValidator.validate('https://www.instagram.com/reel/123').platform, 'instagram');
    });

    test('linkedin.com resolves to linkedin', () {
      expect(UrlValidator.validate('https://linkedin.com/post/123').platform, 'linkedin');
    });

    test('reddit.com, redd.it resolve to reddit', () {
      expect(UrlValidator.validate('https://reddit.com/r/videos/123').platform, 'reddit');
      expect(UrlValidator.validate('https://redd.it/123').platform, 'reddit');
    });

    test('unsupported host returns error with exact message', () {
      final res = UrlValidator.validate('https://tiktok.com/video/123');
      expect(res.isSuccess, isFalse);
      expect(res.error, "Reelcraft doesn't support links from this site yet.");
    });

    test('tracking params stripped: two URLs differing only by ?igsh= produce identical canonicalUrl', () {
      final res1 = UrlValidator.validate('https://www.instagram.com/reel/123?igsh=abc&other=keep');
      final res2 = UrlValidator.validate('https://www.instagram.com/reel/123?igsh=xyz&other=keep');
      final res3 = UrlValidator.validate('https://www.instagram.com/reel/123?other=keep');

      expect(res1.canonicalUrl, 'https://www.instagram.com/reel/123?other=keep');
      expect(res2.canonicalUrl, res1.canonicalUrl);
      expect(res3.canonicalUrl, res1.canonicalUrl);
    });

    test('all specified tracking params are stripped', () {
      final url = 'https://youtube.com/watch?v=123&igsh=1&si=2&utm_source=3&utm_medium=4&utm_campaign=5&fbclid=6';
      final res = UrlValidator.validate(url);
      expect(res.canonicalUrl, 'https://youtube.com/watch?v=123');
    });
  });
}
