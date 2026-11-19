class UserProfile {
  final String userId;
  final String? fullName;
  final String reminderTime; // Format "HH:mm:ss"
  final bool isReminderEnabled;
  final DateTime? updatedAt;

  UserProfile({
    required this.userId,
    this.fullName,
    this.reminderTime = '05:30:00',
    this.isReminderEnabled = true,
    this.updatedAt,
  });

  int get reminderHour {
    try {
      return int.parse(reminderTime.split(':')[0]);
    } catch (_) {
      return 5;
    }
  }

  int get reminderMinute {
    try {
      return int.parse(reminderTime.split(':')[1]);
    } catch (_) {
      return 30;
    }
  }

  String get formattedReminderTime {
    return '${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}';
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id']?.toString() ?? '',
      fullName: map['full_name'],
      reminderTime: map['reminder_time']?.toString() ?? '05:30:00',
      isReminderEnabled: map['is_reminder_enabled'] ?? true,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'reminder_time': reminderTime,
      'is_reminder_enabled': isReminderEnabled,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
