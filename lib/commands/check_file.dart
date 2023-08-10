import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:domine/misc.dart';
import 'package:domine/spinner.dart';

class CheckFileCommand extends Command {
  @override
  String get description => 'Check the availability of domain(s) from a file';

  @override
  String get name => 'check-file';

  @override
  List<String> get aliases => ['cf'];

  @override
  String get invocation => 'check-file <file>';

  CheckFileCommand();

  @override
  void run() async {
    final results = argResults!;
    final input = results.rest.map((e) => e.replaceAll('"', '').trim());

    final file = File(input.first);
    if (input.isEmpty) return stdout.writeln('Domains are empty.');
    if (!await file.exists()) return stdout.writeln('File does not exist.');

    final spinner = Spinner('Heating up...');

    if (stdout.hasTerminal) spinner.start();

    checkDomainsWithCLI(await file.readAsLines(), spinner: spinner);
  }
}
