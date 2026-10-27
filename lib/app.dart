import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/details/deep_link/product_deep_link_handler.dart';
import 'features/splash/screens/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class EcommerceAppHumaVolve extends StatefulWidget {
  const EcommerceAppHumaVolve({super.key});

  @override
  State<EcommerceAppHumaVolve> createState() => _EcommerceAppHumaVolveState();
}

class _EcommerceAppHumaVolveState extends State<EcommerceAppHumaVolve> {
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _deepLinkSubscription = ProductDeepLinkHandler().listen(rootNavigatorKey);
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
