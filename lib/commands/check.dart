import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:cli_spinner/cli_spinner.dart';
import 'package:domine/constants.dart';
import 'package:domine/misc.dart';
import 'package:domine/models.dart';
import 'package:http/http.dart';
import 'package:tint/tint.dart';

class SearchCommand extends Command {
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

    final futures = <Future>[];

    for (final domain in input) {
      for (final variant in expand(domain)) {
        final parts = variant.split('.');
        final name = parts.first;
        final tld = parts.sublist(1).join('.');

        futures.add(check(name, tlds: tld == '*' ? asteriskTLDs : [tld]));
      }
    }

    final checks = await Future.wait(futures);
    final results = [
      for (final check in checks) ...[for (final domain in check) domain]
    ]..sort();
    final successes = results.where((e) => e.status == CheckStatus.available);

    spinner
      ..updateMessage(
        (successes.isNotEmpty
                ? '${successes.length} domains are available'
                : 'All domains have been taken')
            .dim()
            .underline(),
      )
      ..stop();

    table([
      for (final domain in results)
        '${(switch(domain.status) {
          CheckStatus.available => '✔'.green(),
          CheckStatus.taken => '⨯'.red(),
          _ => '⁇'.blue(),
        }).bold()} ${domain.name}.${domain.tld}'
    ]);
  }
}

int hash(String name, int t) {
  for (int o = 0; o < name.length; o++) {
    t = ((t << 5) - t + name.codeUnitAt(o)).toSigned(32);
  }

  return t;
}

Future<List<CheckedDomain>> check(String name,
    {required List<String> tlds}) async {
  final parameters = {
    'tlds': tlds.join(','),
    'hash': hash(name, 27).toString(),
  };

  final dnsNamesReponse = await get(
    Uri.https(
      'instantdomainsearch.com',
      '/services/dns-names/$name',
      parameters,
    ),
  );

  final zoneNamesReponse = await get(
    Uri.https(
      'instantdomainsearch.com',
      '/services/zone-names/$name',
      parameters,
    ),
  );

  final decoded = [
    if (zoneNamesReponse.body.isNotEmpty)
      ...zoneNamesReponse.body.trim().split('\n'),
    if (dnsNamesReponse.body.isNotEmpty)
      ...dnsNamesReponse.body.trim().split('\n'),
  ].map((e) => jsonDecode(e));

  return [
    for (final check in decoded)
      CheckedDomain(
        name,
        check['tld'],
        status: switch (check['isRegistered']) {
          true => CheckStatus.taken,
          false => CheckStatus.available,
          _ => CheckStatus.unknown,
        },
      )
  ];
}
