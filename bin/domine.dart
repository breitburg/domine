import 'package:args/command_runner.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:domine/commands/brainstorm.dart';
import 'package:domine/commands/check.dart';
import 'package:domine/singletones.dart';

void main(List<String> arguments) async {
  // Add retry interceptor
  dio.interceptors.add(RetryInterceptor(dio: dio));

  final runner = CommandRunner(
    'domine',
    'Search and purchase domains right from the terminal.',
  );

  runner.addCommand(CheckCommand());
  runner.addCommand(BrainstormCommand());

  runner.run(arguments);
}
