class BatteryTelemetry {
  final int voltage;
  final double temperature;
  final int batteryLevel;
  final String chargeStatus;
  final int maxCapacity;
  final String pluggedStatus;
  final String health;
  final String manufacturer;
  final String model;

  const BatteryTelemetry({
    required this.voltage,
    required this.temperature,
    required this.batteryLevel,
    required this.chargeStatus,
    required this.maxCapacity,
    required this.pluggedStatus,
    required this.health,
    required this.manufacturer,
    required this.model,
  });
}