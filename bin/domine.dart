import 'package:args/command_runner.dart';
import 'package:domine/commands/check.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner(
    'domine',
    'Search and purchase domains right from the terminal.',
  );

  runner.addCommand(SearchCommand());
  runner.run(arguments);
}
