import 'dart:async';
import 'dart:io';

import 'package:tint/tint.dart';

class Spinner {
  final List<String> states;
  final Duration animationSpeed;
  static Duration frameRate = const Duration(milliseconds: 100);

  late DateTime startDate;
  late Timer timer;

  String _text;

  String get text => _text;
  set text(String value) {
    _text = value;
    draw();
  }

  Spinner(
    this._text, {
    this.states = const ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'],
    this.animationSpeed = const Duration(milliseconds: 250),
  }) : assert(animationSpeed > Spinner.frameRate);

  void start() {
    startDate = DateTime.now();
    timer = Timer.periodic(frameRate, (Timer timer) => draw());
  }

  void draw() {
    final delta = DateTime.now().difference(startDate);

    stdout.write([
      '\r',
      '${states[(delta.inMilliseconds ~/ animationSpeed.inMilliseconds) % states.length]} '
          .dim(),
      '$text ',
      '(${(delta.inMilliseconds / 1000).toStringAsFixed(1)} sec.) '.dim(),
    ].join());
  }

  void cleanup() {
    stdout.write(['\r', ' ' * stdout.terminalColumns, '\r'].join());
  }

  void stop() {
    cleanup();
    timer.cancel();
  }
}
