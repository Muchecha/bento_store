class CalculateResponsive {
  static double fontSize(double screenWidth,
      double percentage,
      double minSize,
      double maxSize) {
    final size = screenWidth * percentage;
    return size.clamp(minSize, maxSize);
  }
}