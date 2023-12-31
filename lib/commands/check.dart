import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:domine/misc.dart';
import 'package:domine/spinner.dart';

class CheckCommand extends Command {
  @override
  String get description => 'Check domain(s) availability';

  @override
  String get name => 'check';

  @override
  List<String> get aliases => ['c'];

  @override
  String get invocation => 'check <query>';

  CheckCommand();

  @override
  void run() async {
    final results = argResults!;
    final input = results.rest.map((e) => e.replaceAll('"', '').trim());

    if (input.isEmpty) return stdout.writeln('Domains are empty.');
    if (input.any((e) => e.split('.').length != 2)) {
      return stdout.writeln('Invalid domains');
    }

    final spinner = Spinner('Heating up...');

    if (stdout.hasTerminal) spinner.start();

    checkDomainsWithCLI(input, spinner: spinner);
  }
}
