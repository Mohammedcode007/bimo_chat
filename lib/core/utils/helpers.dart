String cleanVisibleText(String input) {
  return input
      // Zero width / invisible chars
      .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u206F]'), '')

      // Variation selectors
      .replaceAll(RegExp(r'[\uFE00-\uFE0F]'), '')

      // Combining diacritics كثيرة تسبب اختفاء أو تداخل
      .replaceAll(RegExp(r'[\u0300-\u036F]'), '')
      .replaceAll(RegExp(r'[\u1AB0-\u1AFF]'), '')
      .replaceAll(RegExp(r'[\u1DC0-\u1DFF]'), '')
      .replaceAll(RegExp(r'[\u20D0-\u20FF]'), '')
      .replaceAll(RegExp(r'[\uFE20-\uFE2F]'), '')

      // Khmer / Meetei combining marks التي ظهرت في نصك
      .replaceAll(RegExp(r'[\u17B4-\u17B5]'), '')
      .replaceAll(RegExp(r'[\uAA7B-\uAA7D]'), '')
      .trim();
}