import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:domine/commands/brainstorm.dart';
import 'package:domine/commands/check.dart';
import 'package:domine/spinner.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner(
    'domine',
    'Search and purchase domains right from the terminal.',
  );

  runner.addCommand(CheckCommand());
  runner.addCommand(BrainstormCommand());

  runner.run(arguments);
}
