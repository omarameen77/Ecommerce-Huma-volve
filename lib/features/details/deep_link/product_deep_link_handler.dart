import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../screens/product_details_loader_screen.dart';
import 'product_deep_link_parser.dart';

class DeepLinkReadiness {
  DeepLinkReadiness._();

  static final Completer<void> _completer = Completer<void>();

  static Future<void> get ready => _completer.future;

  static void markReady() {
    if (!_completer.isCompleted) _completer.complete();
  }
}

class ProductDeepLinkHandler {
  factory ProductDeepLinkHandler() => _instance;

  ProductDeepLinkHandler._internal({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  static final ProductDeepLinkHandler _instance =
      ProductDeepLinkHandler._internal();

  final AppLinks _appLinks;
  Uri? _lastHandledUri;

  StreamSubscription<Uri> listen(GlobalKey<NavigatorState> navigatorKey) {
    return _appLinks.uriLinkStream.listen(
      (uri) => _handle(uri, () => navigatorKey.currentState),
      onError: (_) {},
    );
  }

  Future<void> handleInitialLink(NavigatorState? navigatorState) async {
    final uri = await _appLinks.getInitialLink();
    if (uri == null) return;
    await _handle(uri, () => navigatorState);
  }

  Future<void> _handle(
    Uri uri,
    NavigatorState? Function() getNavigatorState,
  ) async {
    if (_lastHandledUri == uri) return;

    final productId = parseProductDeepLinkId(uri);
    if (productId == null) return;

    _lastHandledUri = uri;
    await DeepLinkReadiness.ready;

    getNavigatorState()?.push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsLoaderScreen(productId: productId),
      ),
    );
  }
}
