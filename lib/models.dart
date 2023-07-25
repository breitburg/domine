class CheckedDomain implements Comparable<CheckedDomain> {
  final String name, tld;
  final bool available;

  const CheckedDomain(this.name, this.tld, {required this.available});

  @override
  String toString() => '$name.$tld (available: $available)';

  @override
  int compareTo(CheckedDomain other) => available && !other.available ? -1 : 1;
}
