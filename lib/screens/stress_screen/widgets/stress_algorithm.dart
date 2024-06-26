//Stress calculations
class StressCalculator {
  double calculateStress(
      double heartRate, double hrv, String activityType, int duration) {
    double baselineRHR = heartRate;

    // Calculate stress based on heart rate, heart rate variability, and activity type
    double stress =
        calculateHeartRateStress(baselineRHR) + calculateHRVStress(hrv);
    calculateActivityStress(activityType, duration);

    // Ensure stress values are within a meaningful range
    stress = clampStressValues(stress);

    return stress / 3;
  }

  double calculateHeartRateStress(double baselineRHR) {
    //Stress increases if heart rate is significantly above baseline
    return baselineRHR * 0.1;
  }

  double calculateHRVStress(double hrv) {
    //Stress increases if HRV is significantly below baseline
    return hrv * 0.2;
  }

  double calculateActivityStress(String activityType, int duration) {
    //Stress increases for high-intensity and long-duration activities
    double intensityFactor = (activityType == 'high_intensity') ? 0.3 : 0.0;
    double durationFactor = duration > 60 ? 0.2 : 0.0;

    return intensityFactor + durationFactor;
  }

  double clampStressValues(double stress) {
    // Ensure stress values are within a meaningful range from 0 to 10
    return stress.clamp(0.0, 100.0);
  }
}
