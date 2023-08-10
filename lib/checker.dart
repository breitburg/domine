import 'dart:convert';

import 'package:domine/constants.dart';
import 'package:domine/misc.dart';
import 'package:domine/models.dart';
import 'package:domine/singletones.dart';

Stream<CheckedDomain> batchCheck(Iterable<String> input) async* {
  final checks = <Future>[];

  for (final domain in input) {
    for (final variant in expand(domain)) {
      final parts = variant.split('.');
      assert(parts.length == 2);

      final name = parts.first;
      final tld = parts.last;

      checks.add(
        check(name, tlds: tld == '*' ? asteriskTLDs : [tld]),
      );
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

  final decoded = [
    for (final response in await Future.wait([
      'https://instantdomainsearch.com/services/zone-names/$name',
      'https://instantdomainsearch.com/services/dns-names/$name',
    ].map((String address) => dio.get(address, queryParameters: parameters))))
      if (response.data != null && response.data.isNotEmpty)
        ...response.data.trim().split('\n'),
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
