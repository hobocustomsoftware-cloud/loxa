class TokenPair {
  final String access;
  final String refresh;
  const TokenPair({required this.access, required this.refresh});

  factory TokenPair.fromJson(Map<String, dynamic> j) => TokenPair(
    access: (j['access'] ?? '') as String,
    refresh: (j['refresh'] ?? '') as String,
  );
}
