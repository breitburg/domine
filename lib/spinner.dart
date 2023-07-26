import 'dart:async';
import 'dart:io';

import 'package:tint/tint.dart';

class Spinner {
  final List<String> states;
  final Duration animationSpeed;
  static Duration frameRate = const Duration(milliseconds: 100);

  late String text;
  late Timer timer;

  Spinner(
    this.text, {
    this.states = const ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'],
    this.animationSpeed = const Duration(milliseconds: 250),
  }) : assert(animationSpeed > Spinner.frameRate);

  void start() {
    final start = DateTime.now();

    timer = Timer.periodic(frameRate, (Timer timer) {
      final delta = DateTime.now().difference(start);

      stdout.write([
        '\r',
        '${states[(delta.inMilliseconds ~/ animationSpeed.inMilliseconds) % states.length]} '
            .dim(),
        '$text ',
        '(${(delta.inMilliseconds / 1000).toStringAsFixed(1)} sec.) '.dim(),
      ].join());
    });
  }

  void stop() {
    stdout.write(['\r', ' ' * stdout.terminalColumns, '\r'].join());
    timer.cancel();
  }
}
