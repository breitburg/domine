import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:cli_spinner/cli_spinner.dart';
import 'package:http/http.dart';
import 'package:tint/tint.dart';

const usualTlds = ['com', 'org', 'net', 'me', 'co', 'app', 'io', 'dev'];

class SearchCommand extends Command {
  @override
  String get description => 'Check domain(s) availability';

  @override
  String get name => 'check';

  @override
  List<String> get aliases => ['c'];

  @override
  void run() async {
    final input = argResults?.arguments ?? [];
    if (input.isEmpty) return print('Domains are empty.');

    final spinner =
        Spinner.type('Checking domains availability...', SpinnerType.boxCircle)
          ..start();

    final futures = <Future>[];

    for (final domain in input) {
      for (final variant in expand(domain)) {
        final parts = variant.split('.');
        final name = parts.first;
        final tld = parts.sublist(1).join('.');

        futures.add(check(
          name,
          tlds: tld == '*' ? usualTlds : [variant.replaceFirst('$name.', '')],
        ));
      }
    }

    final checks = await Future.wait(futures);
    final results = [
      for (final check in checks) ...[for (final domain in check) domain]
    ]..sort();
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

    table([
      for (final domain in results)
        '${domain.available ? '✔'.green().bold() : '⨯'.red().bold()} ${domain.name}.${domain.tld}'
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
      CheckedDomain(name, check['tld'], available: !check['isRegistered'])
  ];
}

class CheckedDomain implements Comparable<CheckedDomain> {
  final String name, tld;
  final bool available;

  const CheckedDomain(this.name, this.tld, {required this.available});

  @override
  String toString() => '$name.$tld (available: $available)';

  @override
  int compareTo(CheckedDomain other) => available && !other.available ? -1 : 1;
}

void table(List<String> input) {
  const int columnCount = 4;
  int remaining = columnCount - (input.length % columnCount), i;
  if (remaining < columnCount) {
    for (i = 0; i < remaining; i++) {
      input.add('');
    }
  }
  for (i = 0; i < input.length; i += columnCount) {
    String row = '';
    for (int j = 0; j < columnCount; j++) {
      if (input[i + j] == '') continue;
      row += '${input[i + j]}\t';
    }
    print(row);
  }
}

List<String> expand(String input) {
  final matches = RegExp(r'\[(.*?)\]').firstMatch(input);
  if (matches == null) return [input];

  final results = <String>[];
  final range = matches.group(1)!.split('-');

  // Check if the range is numeric or character
  if (range[0].codeUnitAt(0) >= 48 && range[0].codeUnitAt(0) <= 57) {
    int lowerBound = int.parse(range[0]);
    int upperBound = int.parse(range[1]);

    for (var i = lowerBound; i <= upperBound; i++) {
      var newInput = input.replaceFirst(matches.group(0)!, i.toString());
      results.addAll(expand(newInput));
    }
  } else {
    int lowerBound = range[0].codeUnitAt(0);
    int upperBound = range[1].codeUnitAt(0);

    for (var i = lowerBound; i <= upperBound; i++) {
      var expanded = String.fromCharCode(i);
      var newInput = input.replaceFirst(matches.group(0)!, expanded);
      results.addAll(expand(newInput));
    }
  }

  return results;
}
