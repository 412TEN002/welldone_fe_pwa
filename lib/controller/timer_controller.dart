import 'dart:async';

class TimerController {
  late Timer _timer;
  int _remainingTime = 0;
  Function(int)? _onTick;
  Function()? _onComplete;
  bool isPaused = false;

  void startTimer(int seconds, Function(int) onTick, {Function()? onComplete}) {
    _remainingTime = seconds;
    _onTick = onTick;
    _onComplete = onComplete;
    isPaused = false;

    _runTimer();
  }

  void _runTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        _remainingTime--;

        if (_onTick != null) {
          _onTick!(_remainingTime);
        }

        if (_remainingTime <= 0) {
          timer.cancel();
          if (_onComplete != null) {
            _onComplete!();
          }
        }
      }
    });
  }

  void pauseTimer() {
    isPaused = true;
  }

  void resumeTimer() {
    isPaused = false;
  }

  void resetTimer(int seconds) {
    _timer.cancel();
    _remainingTime = seconds;
    isPaused = false;

    _runTimer();
  }

  void dispose() {
    _timer.cancel();
  }
}
