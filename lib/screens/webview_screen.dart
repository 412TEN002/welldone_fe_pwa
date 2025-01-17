import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:welldone/controller/notification_controller.dart';
import 'package:welldone/controller/timer_controller.dart';
import 'package:welldone/controller/tts_controller.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  final TimerController _timerController = TimerController();
  final NotificationController _notificationController =
      NotificationController();
  final TTSController _ttsController = TTSController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController();
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("TimerRequestChannel",
          onMessageReceived: (message) {
        final command = message.message.split(":");
        if (command.isNotEmpty) {
          switch (command[0]) {
            case "start":
              final time = int.tryParse(command[1]) ?? 0;
              _timerController.startTimer(time, _updateWebViewTimer,
                  onComplete: _onTimerComplete);
              break;
            case "pause":
              _timerController.pauseTimer();
              break;
            case "resume":
              _timerController.resumeTimer();
              break;
            case "reset":
              final time = int.tryParse(command[1]) ?? 0;
              _timerController.resetTimer(time);
              _updateWebViewTimer(time);
              break;
          }
        }
      })
      ..runJavaScript('''
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        document.head.appendChild(meta);
      ''')
      ..loadRequest(Uri.parse("https://welldone-fe-next-app.vercel.app/"))
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
          },
        ),
      );
  }

  void _updateWebViewTimer(int remainingTime) {
    _controller.runJavaScript('window.updateTimer($remainingTime);');
  }

  void _onTimerComplete() async {
    await _notificationController.showNotification("타이머 완료", "타이머가 종료되었습니다!");
    await _ttsController.speak("타이머가 종료되었습니다!");
  }

  @override
  void dispose() {
    _timerController.dispose();
    _ttsController.stop();
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        minimum: EdgeInsets.zero,
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
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
