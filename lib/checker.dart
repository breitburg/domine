import 'dart:convert';

import 'package:domine/constants.dart';
import 'package:domine/misc.dart';
import 'package:domine/models.dart';
import 'package:http/http.dart';

Stream<CheckedDomain> batchCheck(Iterable<String> input) async* {
  final checks = <Future>[];

  for (final domain in input) {
    for (final variant in expand(domain)) {
      final parts = variant.split('.');
      final name = parts.first;
      final tld = parts.sublist(1).join('.');

      checks.add(check(name, tlds: tld == '*' ? asteriskTLDs : [tld]));
    }
  }

  await for (final checked in Stream.fromFutures(checks)) {
    yield* Stream.fromIterable(checked);
  }
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

int hash(String name, int t) {
  for (int o = 0; o < name.length; o++) {
    t = ((t << 5) - t + name.codeUnitAt(o)).toSigned(32);
  }

  return t;
}
