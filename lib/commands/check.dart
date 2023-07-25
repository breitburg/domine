import 'package:args/command_runner.dart';
import 'package:cli_spinner/cli_spinner.dart';
import 'package:domine/checker.dart';
import 'package:domine/misc.dart';
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
    if (input.isEmpty) return print('Domains are empty.');

    final spinner = Spinner.type('Checking availability...', SpinnerType.dots)
      ..start();

    final results = await batchCheck(input);
    final successes = results.where((e) => e.available);

    spinner
      ..updateMessage(
        (successes.isNotEmpty
                ? '${successes.length} domains are available'
                : 'All domains have been taken')
            .dim()
            .underline(),
      )
      ..stop();

    domainTable(results);
  }
}
