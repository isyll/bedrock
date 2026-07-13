bool isVersionNewer(String candidate, String current) {
  final candidateParts = _segments(candidate);
  final currentParts = _segments(current);
  final length = candidateParts.length > currentParts.length
      ? candidateParts.length
      : currentParts.length;

  for (var index = 0; index < length; index++) {
    final candidatePart = index < candidateParts.length
        ? candidateParts[index]
        : 0;
    final currentPart = index < currentParts.length ? currentParts[index] : 0;
    if (candidatePart != currentPart) return candidatePart > currentPart;
  }

  return false;
}

List<int> _segments(String version) =>
    version.split('.').map((part) => int.tryParse(part.trim()) ?? 0).toList();
