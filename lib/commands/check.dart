import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:domine/checker.dart';
import 'package:domine/misc.dart';
import 'package:domine/spinner.dart';
import 'package:tint/tint.dart';

class CheckCommand extends Command {
  @override
  String get description => 'Check domain(s) availability';

  @override
  String get name => 'check';

  @override
  List<String> get aliases => ['c'];

  @override
  String get invocation => 'check <query>';

  @override
  void run() async {
    final input = (argResults?.rest ?? []).map(
      (e) => e.replaceAll('"', '').trim(),
    );
    if (input.isEmpty) return stdout.writeln('Domains are empty.');

    final spinner = Spinner('Checking availability...');

    if (stdout.hasTerminal) {
      spinner.start();
    }

    final results = await batchCheck(input);
    final successes = results.where((e) => e.available);

    if (stdout.hasTerminal) {
      spinner.stop();
      stdout.writeln((successes.isNotEmpty
              ? '${successes.length} ${successes.length > 1 ? 'domains are' : 'domain is'} available'
              : 'All domains have been taken')
          .dim()
          .underline());

      domainTable(results);
      return;
    }

    stdout.writeln(successes.join('\n'));
  }
}
