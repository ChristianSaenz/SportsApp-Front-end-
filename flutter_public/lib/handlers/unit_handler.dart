class UnitConverter {
  static String convertHeightToFeet(int heightCm) {
    final heightInInches = heightCm / 2.54;
    final feet = heightInInches ~/ 12;
    final inches = (heightInInches % 12).round();
    return '$feet\'$inches"';
  }

  static String convertWeightToPounds(int weightKg) {
    final weightInLbs = (weightKg * 2.20462).round();
    return '$weightInLbs lbs';
  }
}
