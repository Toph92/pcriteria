
/// Extension on [String] to support accent-insensitive search and other string utilities
extension RemoveAccentsExtension on String {
  /// Removes diacritics (accents) from a string.
  /// Handles both NFC (single character) and NFD (base + combining mark) normalization.
  String removeAccents() {
    String text = this;
    
    // Explicit replacements for common accented characters
    const withDia = 'àáâãäåòóôõöøèéêëìíîïùúûüÿñçÀÁÂÃÄÅÒÓÔÕÖØÈÉÊËÌÍÎÏÙÚÛÜÝÑÇ';
    const withoutDia = 'aaaaaaooooooeeeeiiiiuuuuyñcAAAAAAOOOOOOEEEEIIIIUUUUYNÇ';
    
    var result = text;
    for (int i = 0; i < withDia.length; i++) {
        result = result.replaceAll(withDia[i], withoutDia[i]);
    }
    
    // Handle NFD: remove combining diacritics marks
    result = result.replaceAll(RegExp(r'[\u0300-\u036f]'), '');
    
    return result;
  }

  /// Converts a string to a format suitable for search (case-insensitive and accent-insensitive)
  String toSearchable() {
    return removeAccents().toLowerCase();
  }

  /// Checks if this string contains any of the provided [keywords]
  bool containsAny(List<String> keywords) {
    return keywords.any((keyword) => contains(keyword));
  }

  /// Checks if this string contains all of the provided [keywords]
  bool containsAll(List<String> keywords) {
    return keywords.every((keyword) => contains(keyword));
  }
}
