import 'dart:convert';

import 'package:domine/constants.dart';
import 'package:domine/misc.dart';
import 'package:domine/models.dart';
import 'package:http/http.dart';

Stream<CheckedDomain> batchCheck(Iterable<String> input,
    {bool retry = true}) async* {
  final checks = <Future>[];

  for (final domain in input) {
    for (final variant in expand(domain)) {
      final parts = variant.split('.');
      assert(parts.length == 2);

      final name = parts.first;
      final tld = parts.last;

      checks.add(
        check(name, tlds: tld == '*' ? asteriskTLDs : [tld], retry: retry),
      );
    }
  }

  await for (final checked in Stream.fromFutures(checks)) {
    yield* Stream.fromIterable(checked);
  }
}

Future<List<CheckedDomain>> check(String name,
    {required List<String> tlds, bool retry = true}) async {
  final parameters = {
    'tlds': tlds.join(','),
    'hash': hash(name, 27).toString(),
  };

  late final Iterable<Map<String, dynamic>> decoded;

  while (true) {
    try {
      decoded = [
        for (final response in await Future.wait([
          Uri.https(
            'instantdomainsearch.com',
            '/services/zone-names/$name',
            parameters,
          ),
          Uri.https(
            'instantdomainsearch.com',
            '/services/dns-names/$name',
            parameters,
          ),
        ].map(get)))
          if (response.body.isNotEmpty) ...response.body.trim().split('\n'),
      ].map((e) => jsonDecode(e));
      break;
    } catch (_) {
      if (!retry) rethrow;
      await Future.delayed(const Duration(seconds: 2));
    }
  }

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
