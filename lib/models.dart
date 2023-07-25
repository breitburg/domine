class CheckedDomain implements Comparable<CheckedDomain> {
  final String name, tld;
  final CheckStatus status;

  const CheckedDomain(this.name, this.tld, {required this.status});

  bool get available => status == CheckStatus.available;

  @override
  String toString() => '$name.$tld';

  @override
  int compareTo(CheckedDomain other) =>
      status.index.compareTo(other.status.index);
}

enum CheckStatus { available, unknown, taken }
