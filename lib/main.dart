import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:welldoness/screens/webview_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Timer(const Duration(seconds: 1), () {
    FlutterNativeSplash.remove();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'welldone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white54),
        useMaterial3: true,
      ),
      home: const WebViewScreen(),
    );
  }
}
