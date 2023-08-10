import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:domine/checker.dart';
import 'package:domine/misc.dart';
import 'package:domine/models.dart';
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
    final checked = <CheckedDomain>[];

    if (stdout.hasTerminal) spinner.start();

    await for (final domain in batchCheck(input)) {
      checked.add(domain);

      spinner.text = '${domain.toString().underline()} was checked...';
    }

    if (stdout.hasTerminal) {
      spinner.stop();

      final successes = checked.where((e) => e.available);
      stdout.writeln((successes.isNotEmpty
              ? '${successes.length} ${successes.length > 1 ? 'domains are' : 'domain is'} available'
              : 'All domains have been taken')
          .dim()
          .underline());
    }

    domainTable(checked);
  }
}
