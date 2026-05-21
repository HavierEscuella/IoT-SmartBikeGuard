class BikeData {
  final String ownerName;
  final String ownerPhone;
  final String bikeName;
  final String bikeType;
  final String serialNumber;
  final double sensitivity;
  final int alertCount;
  final bool isOfflineMode;

  const BikeData({
    required this.ownerName,
    required this.ownerPhone,
    required this.bikeName,
    required this.bikeType,
    required this.serialNumber,
    required this.sensitivity,
    required this.alertCount,
    required this.isOfflineMode,
  });

  BikeData copyWith({
    String? ownerName,
    String? ownerPhone,
    String? bikeName,
    String? bikeType,
    String? serialNumber,
    double? sensitivity,
    int? alertCount,
    bool? isOfflineMode,
  }) {
    return BikeData(
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      bikeName: bikeName ?? this.bikeName,
      bikeType: bikeType ?? this.bikeType,
      serialNumber: serialNumber ?? this.serialNumber,
      sensitivity: sensitivity ?? this.sensitivity,
      alertCount: alertCount ?? this.alertCount,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }
}
