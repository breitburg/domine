class CheckedDomain implements Comparable<CheckedDomain> {
  final String name, tld;
  final CheckStatus status;

  const CheckedDomain(this.name, this.tld, {required this.status});

  @override
  String toString() => '$name.$tld';

  @override
  int compareTo(CheckedDomain other) =>
      status.index.compareTo(other.status.index);
}

enum CheckStatus { available, unknown, taken }
