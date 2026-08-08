class DashboardModel {
  final int todayCalls;
  final int appointments;
  final int revenue;
  final double aiAccuracy;

  final String todayCallsTrend;
  final String appointmentsTrend;
  final String revenueTrend;
  final String aiAccuracyTrend;

  const DashboardModel({
  required this.todayCalls,
  required this.appointments,
  required this.revenue,
  required this.aiAccuracy,

  required this.todayCallsTrend,
  required this.appointmentsTrend,
  required this.revenueTrend,
  required this.aiAccuracyTrend,
});

  factory DashboardModel.fromMap(Map<String, dynamic> map) {
    return DashboardModel(
      todayCalls: map['todayCalls'] as int? ?? 0,
      appointments: map['appointments'] as int? ?? 0,
      revenue: map['revenue'] as int? ?? 0,
      aiAccuracy: (map['aiAccuracy'] as num?)?.toDouble() ?? 0.0,

      todayCallsTrend: map['todayCallsTrend'] as String? ?? '0%',
      appointmentsTrend: map['appointmentsTrend'] as String? ?? '0%',
      revenueTrend: map['revenueTrend'] as String? ?? '0%',
      aiAccuracyTrend: map['aiAccuracyTrend'] as String? ?? '0%',
    );
  }

  Map<String, dynamic> toMap() {
    return {
    'todayCalls': todayCalls,
    'appointments': appointments,
    'revenue': revenue,
    'aiAccuracy': aiAccuracy,

    'todayCallsTrend': todayCallsTrend,
    'appointmentsTrend': appointmentsTrend,
    'revenueTrend': revenueTrend,
    'aiAccuracyTrend': aiAccuracyTrend,
};
  }

  
  DashboardModel copyWith({
  int? todayCalls,
  int? appointments,
  int? revenue,
  double? aiAccuracy,

  String? todayCallsTrend,
  String? appointmentsTrend,
  String? revenueTrend,
  String? aiAccuracyTrend,
}) {
    return DashboardModel(
      todayCalls: todayCalls ?? this.todayCalls,
      appointments: appointments ?? this.appointments,
      revenue: revenue ?? this.revenue,
      aiAccuracy: aiAccuracy ?? this.aiAccuracy,

      todayCallsTrend: todayCallsTrend ?? this.todayCallsTrend,
      appointmentsTrend: appointmentsTrend ?? this.appointmentsTrend,
      revenueTrend: revenueTrend ?? this.revenueTrend,
      aiAccuracyTrend: aiAccuracyTrend ?? this.aiAccuracyTrend,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is DashboardModel &&
      other.todayCalls == todayCalls &&
      other.appointments == appointments &&
      other.revenue == revenue &&
      other.aiAccuracy == aiAccuracy &&

      other.todayCallsTrend == todayCallsTrend &&
      other.appointmentsTrend == appointmentsTrend &&
      other.revenueTrend == revenueTrend &&
      other.aiAccuracyTrend == aiAccuracyTrend;
  }

  @override
  int get hashCode {
    return todayCalls.hashCode ^
      appointments.hashCode ^
      revenue.hashCode ^
    aiAccuracy.hashCode ^
      todayCallsTrend.hashCode ^
      appointmentsTrend.hashCode ^
      revenueTrend.hashCode ^
      aiAccuracyTrend.hashCode;
  }
}