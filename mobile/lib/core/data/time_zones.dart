// lib/core/data/time_zones.dart

/// Time zone data for onboarding Screen 3.
/// Each entry maps an IANA timezone ID to a human-readable label.
/// Keep this list in sync with the IANA tz database.
class TimeZoneOption {
  const TimeZoneOption({
    required this.ianaId,
    required this.displayName,
  });

  final String ianaId;
  final String displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeZoneOption &&
          runtimeType == other.runtimeType &&
          ianaId == other.ianaId &&
          displayName == other.displayName;

  @override
  int get hashCode => Object.hash(ianaId, displayName);
}

/// Curated list of common timezones covering all major regions.
/// Ordered roughly by region: UTC, Americas, Europe, Africa, Asia, Oceania.
const List<TimeZoneOption> timeZoneOptions = [
  // UTC
  TimeZoneOption(ianaId: 'UTC', displayName: 'Coordinated Universal Time (UTC)'),

  // Americas
  TimeZoneOption(ianaId: 'America/Adak', displayName: 'Hawaii-Aleutian Standard Time (HST)'),
  TimeZoneOption(ianaId: 'America/Anchorage', displayName: 'Alaska Standard Time (AKST)'),
  TimeZoneOption(ianaId: 'America/Los_Angeles', displayName: 'Pacific Time (PT)'),
  TimeZoneOption(ianaId: 'America/Denver', displayName: 'Mountain Time (MT)'),
  TimeZoneOption(ianaId: 'America/Phoenix', displayName: 'Mountain Standard Time - Arizona (MST)'),
  TimeZoneOption(ianaId: 'America/Chicago', displayName: 'Central Time (CT)'),
  TimeZoneOption(ianaId: 'America/New_York', displayName: 'Eastern Time (ET)'),
  TimeZoneOption(ianaId: 'America/Indiana/Indianapolis', displayName: 'Eastern Time - Indiana (ET)'),
  TimeZoneOption(ianaId: 'America/Toronto', displayName: 'Eastern Time - Toronto (ET)'),
  TimeZoneOption(ianaId: 'America/Vancouver', displayName: 'Pacific Time - Vancouver (PT)'),
  TimeZoneOption(ianaId: 'America/Edmonton', displayName: 'Mountain Time - Edmonton (MT)'),
  TimeZoneOption(ianaId: 'America/Winnipeg', displayName: 'Central Time - Winnipeg (CT)'),
  TimeZoneOption(ianaId: 'America/Halifax', displayName: 'Atlantic Time (AT)'),
  TimeZoneOption(ianaId: 'America/St_Johns', displayName: 'Newfoundland Time (NST)'),
  TimeZoneOption(ianaId: 'America/Mexico_City', displayName: 'Central Time - Mexico City (CST)'),
  TimeZoneOption(ianaId: 'America/Guatemala', displayName: 'Central America Standard Time (CST)'),
  TimeZoneOption(ianaId: 'America/Managua', displayName: 'Central America Standard Time (CST)'),
  TimeZoneOption(ianaId: 'America/Costa_Rica', displayName: 'Central America Standard Time (CST)'),
  TimeZoneOption(ianaId: 'America/Panama', displayName: 'Eastern Standard Time - Panama (EST)'),
  TimeZoneOption(ianaId: 'America/Bogota', displayName: 'Colombia Time (COT)'),
  TimeZoneOption(ianaId: 'America/Lima', displayName: 'Peru Time (PET)'),
  TimeZoneOption(ianaId: 'America/Caracas', displayName: 'Venezuela Time (VET)'),
  TimeZoneOption(ianaId: 'America/Santiago', displayName: 'Chile Standard Time (CLT)'),
  TimeZoneOption(ianaId: 'America/Argentina/Buenos_Aires', displayName: 'Argentina Time (ART)'),
  TimeZoneOption(ianaId: 'America/Sao_Paulo', displayName: 'Brasilia Time (BRT)'),
  TimeZoneOption(ianaId: 'America/Godthab', displayName: 'Western Greenland Time (WGT)'),

  // Europe
  TimeZoneOption(ianaId: 'Europe/London', displayName: 'Greenwich Mean Time (GMT)'),
  TimeZoneOption(ianaId: 'Europe/Dublin', displayName: 'Greenwich Mean Time - Dublin (GMT)'),
  TimeZoneOption(ianaId: 'Europe/Lisbon', displayName: 'Western European Time (WET)'),
  TimeZoneOption(ianaId: 'Europe/Paris', displayName: 'Central European Time (CET)'),
  TimeZoneOption(ianaId: 'Europe/Berlin', displayName: 'Central European Time - Berlin (CET)'),
  TimeZoneOption(ianaId: 'Europe/Rome', displayName: 'Central European Time - Rome (CET)'),
  TimeZoneOption(ianaId: 'Europe/Madrid', displayName: 'Central European Time - Madrid (CET)'),
  TimeZoneOption(ianaId: 'Europe/Amsterdam', displayName: 'Central European Time - Amsterdam (CET)'),
  TimeZoneOption(ianaId: 'Europe/Brussels', displayName: 'Central European Time - Brussels (CET)'),
  TimeZoneOption(ianaId: 'Europe/Vienna', displayName: 'Central European Time - Vienna (CET)'),
  TimeZoneOption(ianaId: 'Europe/Warsaw', displayName: 'Central European Time - Warsaw (CET)'),
  TimeZoneOption(ianaId: 'Europe/Prague', displayName: 'Central European Time - Prague (CET)'),
  TimeZoneOption(ianaId: 'Europe/Budapest', displayName: 'Central European Time - Budapest (CET)'),
  TimeZoneOption(ianaId: 'Europe/Zurich', displayName: 'Central European Time - Zurich (CET)'),
  TimeZoneOption(ianaId: 'Europe/Stockholm', displayName: 'Central European Time - Stockholm (CET)'),
  TimeZoneOption(ianaId: 'Europe/Oslo', displayName: 'Central European Time - Oslo (CET)'),
  TimeZoneOption(ianaId: 'Europe/Copenhagen', displayName: 'Central European Time - Copenhagen (CET)'),
  TimeZoneOption(ianaId: 'Europe/Helsinki', displayName: 'Eastern European Time (EET)'),
  TimeZoneOption(ianaId: 'Europe/Athens', displayName: 'Eastern European Time - Athens (EET)'),
  TimeZoneOption(ianaId: 'Europe/Bucharest', displayName: 'Eastern European Time - Bucharest (EET)'),
  TimeZoneOption(ianaId: 'Europe/Istanbul', displayName: 'Turkey Time (TRT)'),
  TimeZoneOption(ianaId: 'Europe/Moscow', displayName: 'Moscow Standard Time (MSK)'),
  TimeZoneOption(ianaId: 'Europe/Kaliningrad', displayName: 'Kaliningrad Time (USZ1)'),

  // Africa
  TimeZoneOption(ianaId: 'Africa/Casablanca', displayName: 'Western European Time - Morocco (WET)'),
  TimeZoneOption(ianaId: 'Africa/Algiers', displayName: 'Central European Time - Algeria (CET)'),
  TimeZoneOption(ianaId: 'Africa/Tunis', displayName: 'Central European Time - Tunisia (CET)'),
  TimeZoneOption(ianaId: 'Africa/Tripoli', displayName: 'Eastern European Time - Libya (EET)'),
  TimeZoneOption(ianaId: 'Africa/Cairo', displayName: 'Eastern European Time - Cairo (EET)'),
  TimeZoneOption(ianaId: 'Africa/Johannesburg', displayName: 'South Africa Standard Time (SAST)'),
  TimeZoneOption(ianaId: 'Africa/Lagos', displayName: 'West Africa Time (WAT)'),
  TimeZoneOption(ianaId: 'Africa/Nairobi', displayName: 'East Africa Time (EAT)'),
  TimeZoneOption(ianaId: 'Africa/Khartoum', displayName: 'Central Africa Time (CAT)'),
  TimeZoneOption(ianaId: 'Africa/Addis_Ababa', displayName: 'East Africa Time (EAT)'),

  // Middle East
  TimeZoneOption(ianaId: 'Asia/Jerusalem', displayName: 'Israel Standard Time (IST)'),
  TimeZoneOption(ianaId: 'Asia/Beirut', displayName: 'Eastern European Time - Lebanon (EET)'),
  TimeZoneOption(ianaId: 'Asia/Damascus', displayName: 'Eastern European Time - Syria (EET)'),
  TimeZoneOption(ianaId: 'Asia/Amman', displayName: 'Eastern European Time - Jordan (EET)'),
  TimeZoneOption(ianaId: 'Asia/Baghdad', displayName: 'Arabia Standard Time (AST)'),
  TimeZoneOption(ianaId: 'Asia/Kuwait', displayName: 'Arabia Standard Time (AST)'),
  TimeZoneOption(ianaId: 'Asia/Riyadh', displayName: 'Arabia Standard Time - Riyadh (AST)'),
  TimeZoneOption(ianaId: 'Asia/Qatar', displayName: 'Arabia Standard Time - Qatar (AST)'),
  TimeZoneOption(ianaId: 'Asia/Dubai', displayName: 'Gulf Standard Time (GST)'),
  TimeZoneOption(ianaId: 'Asia/Muscat', displayName: 'Gulf Standard Time - Oman (GST)'),
  TimeZoneOption(ianaId: 'Asia/Tehran', displayName: 'Iran Standard Time (IRST)'),

  // South Asia
  TimeZoneOption(ianaId: 'Asia/Kolkata', displayName: 'India Standard Time (IST)'),
  TimeZoneOption(ianaId: 'Asia/Karachi', displayName: 'Pakistan Standard Time (PKT)'),
  TimeZoneOption(ianaId: 'Asia/Dhaka', displayName: 'Bangladesh Standard Time (BST)'),
  TimeZoneOption(ianaId: 'Asia/Kathmandu', displayName: 'Nepal Time (NPT)'),
  TimeZoneOption(ianaId: 'Asia/Colombo', displayName: 'Sri Lanka Standard Time (SLST)'),
  TimeZoneOption(ianaId: 'Asia/Thimphu', displayName: 'Bhutan Time (BTT)'),

  // Central Asia
  TimeZoneOption(ianaId: 'Asia/Tashkent', displayName: 'Uzbekistan Time (UZT)'),
  TimeZoneOption(ianaId: 'Asia/Almaty', displayName: 'Alma-Ata Time (ALMT)'),
  TimeZoneOption(ianaId: 'Asia/Bishkek', displayName: 'Kyrgyzstan Time (KGT)'),
  TimeZoneOption(ianaId: 'Asia/Dushanbe', displayName: 'Tajikistan Time (TJT)'),
  TimeZoneOption(ianaId: 'Asia/Ashgabat', displayName: 'Turkmenistan Time (TMT)'),

  // Southeast Asia
  TimeZoneOption(ianaId: 'Asia/Yangon', displayName: 'Myanmar Time (MMT)'),
  TimeZoneOption(ianaId: 'Asia/Bangkok', displayName: 'Indochina Time (ICT)'),
  TimeZoneOption(ianaId: 'Asia/Ho_Chi_Minh', displayName: 'Indochina Time - Vietnam (ICT)'),
  TimeZoneOption(ianaId: 'Asia/Phnom_Penh', displayName: 'Indochina Time - Cambodia (ICT)'),
  TimeZoneOption(ianaId: 'Asia/Vientiane', displayName: 'Indochina Time - Laos (ICT)'),
  TimeZoneOption(ianaId: 'Asia/Jakarta', displayName: 'Western Indonesia Time (WIB)'),
  TimeZoneOption(ianaId: 'Asia/Pontianak', displayName: 'Western Indonesia Time (WIB)'),
  TimeZoneOption(ianaId: 'Asia/Makassar', displayName: 'Central Indonesia Time (WITA)'),
  TimeZoneOption(ianaId: 'Asia/Jayapura', displayName: 'Eastern Indonesia Time (WIT)'),
  TimeZoneOption(ianaId: 'Asia/Kuala_Lumpur', displayName: 'Malaysia Time (MYT)'),
  TimeZoneOption(ianaId: 'Asia/Singapore', displayName: 'Singapore Standard Time (SGT)'),
  TimeZoneOption(ianaId: 'Asia/Manila', displayName: 'Philippine Standard Time (PST)'),
  TimeZoneOption(ianaId: 'Asia/Brunei', displayName: 'Brunei Darussalam Time (BNT)'),

  // East Asia
  TimeZoneOption(ianaId: 'Asia/Shanghai', displayName: 'China Standard Time (CST)'),
  TimeZoneOption(ianaId: 'Asia/Hong_Kong', displayName: 'Hong Kong Time (HKT)'),
  TimeZoneOption(ianaId: 'Asia/Taipei', displayName: 'Taipei Standard Time (CST)'),
  TimeZoneOption(ianaId: 'Asia/Seoul', displayName: 'Korea Standard Time (KST)'),
  TimeZoneOption(ianaId: 'Asia/Tokyo', displayName: 'Japan Standard Time (JST)'),
  TimeZoneOption(ianaId: 'Asia/Ulaanbaatar', displayName: 'Ulaanbaatar Time (ULAT)'),

  // Oceania
  TimeZoneOption(ianaId: 'Australia/Perth', displayName: 'Australian Western Standard Time (AWST)'),
  TimeZoneOption(ianaId: 'Australia/Darwin', displayName: 'Australian Central Standard Time (ACST)'),
  TimeZoneOption(ianaId: 'Australia/Adelaide', displayName: 'Australian Central Standard Time - Adelaide (ACST)'),
  TimeZoneOption(ianaId: 'Australia/Brisbane', displayName: 'Australian Eastern Standard Time (AEST)'),
  TimeZoneOption(ianaId: 'Australia/Sydney', displayName: 'Australian Eastern Standard Time - Sydney (AEST)'),
  TimeZoneOption(ianaId: 'Australia/Melbourne', displayName: 'Australian Eastern Standard Time - Melbourne (AEST)'),
  TimeZoneOption(ianaId: 'Australia/Hobart', displayName: 'Australian Eastern Standard Time - Hobart (AEST)'),
  TimeZoneOption(ianaId: 'Pacific/Auckland', displayName: 'New Zealand Standard Time (NZST)'),
  TimeZoneOption(ianaId: 'Pacific/Fiji', displayName: 'Fiji Time (FJT)'),
  TimeZoneOption(ianaId: 'Pacific/Guadalcanal', displayName: 'Solomon Islands Time (SBT)'),
  TimeZoneOption(ianaId: 'Pacific/Port_Moresby', displayName: 'Papua New Guinea Time (PGT)'),
];