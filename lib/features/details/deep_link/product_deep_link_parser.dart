const String kProductLinkScheme = 'humavolve';

const String kIllustrativeHttpsHost = 'your-domain.example';

int? parseProductDeepLinkId(Uri uri) {
  if (uri.scheme == kProductLinkScheme) {
    if (uri.host != 'products') return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length != 1) return null;
    return _parsePositiveId(segments.first);
  }

  if (uri.scheme == 'https' || uri.scheme == 'http') {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length != 2 || segments.first != 'products') return null;
    return _parsePositiveId(segments[1]);
  }

  return null;
}

int? _parsePositiveId(String raw) {
  final id = int.tryParse(raw);
  if (id == null || id <= 0) return null;
  return id;
}
