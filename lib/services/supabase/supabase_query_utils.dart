String escapeForLikeQuery(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll('%', '\\%')
    .replaceAll('_', '\\_');

List<String> tokenizeSearchQuery(String query) =>
    query.split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
