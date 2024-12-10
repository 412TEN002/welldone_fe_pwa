import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:welldone/controller/timer_controller.dart';
import 'package:welldone/controller/notification_controller.dart';
import 'package:welldone/controller/tts_controller.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  final TimerController _timerController = TimerController();
  final NotificationController _notificationController = NotificationController();
  final TTSController _ttsController = TTSController();

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
        if(command.isNotEmpty) {
          switch(command[0]){
            case "start":
              final time = int.tryParse(command[1]) ?? 0;
              _timerController.startTimer(time, _updateWebViewTimer, onComplete: _onTimerComplete);
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
      ..loadRequest(Uri.parse("https://ssss-test.vercel.app/"));
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
    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
