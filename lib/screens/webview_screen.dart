import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  late AudioPlayer player = AudioPlayer();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(AssetSource('end_sound.mp3'));
    });

    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController();
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("TimerStatusChannel",
          onMessageReceived: (message) {
        try {
          final Map<String, dynamic> data = jsonDecode(message.message);

          final String status = data['status'];

          switch (status) {
            case "play":
              // 재생 중일 때의 처리
              break;
            case "pause":
              // 일시정지 상태일 때의 처리
              break;
            case "resume":
              break;
            case "end":
              player.resume();
              // 종료 상태일 때의 처리
              break;
            case "reset":
              // 리셋 상태일 때의 처리
              break;
          }
        } catch (e) {
          print('Error parsing message: $e');
        }
      })
      ..runJavaScript('''
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        document.head.appendChild(meta);
      ''')
      ..loadRequest(Uri.parse("https://welldone-fe-next-app-one.vercel.app/"))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
            _controller.clearCache();
          },
        ),
      );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF3C3731),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF3C3731),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: const Color(0xFF3C3731),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        minimum: EdgeInsets.zero,
        child: Container(
          color: const Color(0xFF3C3731),
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: WebViewWidget(controller: _controller),
                  );
                },
              ),
              if (_isLoading)
                Container(
                  color: const Color(0xFF3C3731),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
