bool hasCommonElement(List<String> a, List<String> b) {
  return a.toSet().intersection(b.toSet()).isNotEmpty;
}
