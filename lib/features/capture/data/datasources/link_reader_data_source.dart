import 'package:http/http.dart' as http;

class LinkSummaryResult {
  final String url;
  final String title;
  final String description;

  LinkSummaryResult({
    required this.url,
    required this.title,
    required this.description,
  });
}

class LinkReaderDataSource {
  final http.Client _client;

  LinkReaderDataSource({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch HTML for a URL and extract title and meta description
  Future<LinkSummaryResult> fetchLinkSummary(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final html = response.body;
        final title = _extractTitle(html) ?? uri.host;
        final desc = _extractMetaDescription(html) ?? 'Shared web link from ${uri.host}';

        return LinkSummaryResult(
          url: url,
          title: title,
          description: desc,
        );
      }
    } catch (_) {}

    return LinkSummaryResult(
      url: url,
      title: url,
      description: 'Shared link',
    );
  }

  String? _extractTitle(String html) {
    final titleRegExp = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true);
    final match = titleRegExp.firstMatch(html);
    return match?.group(1)?.trim();
  }

  String? _extractMetaDescription(String html) {
    final metaRegExp = RegExp(r'<meta[^>]*content="([^"]*)"', caseSensitive: false);
    final match = metaRegExp.firstMatch(html);
    return match?.group(1)?.trim();
  }
}
