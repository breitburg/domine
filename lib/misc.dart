import 'package:domine/models.dart';
import 'package:tint/tint.dart';

void domainTable(List<CheckedDomain> domains) {
  table([
    for (final domain in domains..sort())
      '${(switch (domain.status) {
        CheckStatus.available => '✔'.green(),
        CheckStatus.taken => '⨯'.red(),
        _ => '⁇'.blue(),
      }).bold()} $domain'
  ]);
}

void table(List<String> input) {
  const int columnCount = 5;
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
