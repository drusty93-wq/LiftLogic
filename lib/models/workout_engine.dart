enum TrainingStatus { progressed, stalled, deloaded }

class WorkoutEngine {
  /// The step-increment for your gym (usually 2.5kg or 5.0lbs)
  final double unitIncrement;

  WorkoutEngine({this.unitIncrement = 2.5});

  /// Main function to process a session result
  ({double nextWeight, int nextStreak, TrainingStatus status}) processSession({
    required double currentWeight,
    required int repsPerformed,
    required int targetReps,
    required int currentStreak,
  }) {
    // 1. SUCCESS: User hit or exceeded the target
    if (repsPerformed >= targetReps) {
      double nextWeight = _calculateIncrease(currentWeight);
      
      return (
        nextWeight: nextWeight,
        nextStreak: 0, // Reset streak on success
        status: TrainingStatus.progressed,
      );
    }

    // 2. FAILURE: User missed the target
    int newStreak = currentStreak + 1;

    if (newStreak >= 3) {
      // Trigger Deload (10% reduction)
      double deloadWeight = currentWeight * 0.90;
      double roundedDeload = (deloadWeight / unitIncrement).round() * unitIncrement;

      return (
        nextWeight: roundedDeload,
        nextStreak: 0, // Reset streak after deloading
        status: TrainingStatus.deloaded,
      );
    } else {
      // Stall: Keep weight the same
      return (
        nextWeight: currentWeight,
        nextStreak: newStreak,
        status: TrainingStatus.stalled,
      );
    }
  }

  /// Helper to calculate the 1% - 5% increase based on weight
  double _calculateIncrease(double weight) {
    const double lowBoundW = 20.0;
    const double highBoundW = 120.0;
    double percentage;

    // Determine the percentage based on how heavy the lift is
    if (weight <= lowBoundW) {
      percentage = 5.0;
    } else if (weight >= highBoundW) {
      percentage = 1.0;
    } else {
      // Linear interpolation: percentage slides from 5% down to 1%
      percentage = 5.0 - ((weight - lowBoundW) / (highBoundW - lowBoundW) * 4.0);
    }

    double rawNewWeight = weight * (1 + (percentage / 100));
    
    // Round to the nearest gym increment
    double roundedWeight = (rawNewWeight / unitIncrement).round() * unitIncrement;

    // Edge case: If the percentage was so small the weight didn't change, 
    // force an increase of one unitIncrement.
    if (roundedWeight <= weight) {
      roundedWeight = weight + unitIncrement;
    }

    return roundedWeight;
  }
}
