import 'contact_preview.dart';

class CallRecord {
  const CallRecord({
    required this.name,
    required this.phone,
    required this.startedAt,
    this.direction = CallDirection.outgoing,
    this.status = CallStatus.completed,
    this.durationSeconds = 0,
  });

  factory CallRecord.fromContact(ContactPreview contact, DateTime startedAt) {
    return CallRecord(
      name: contact.name,
      phone: contact.phone,
      startedAt: startedAt,
      direction: CallDirection.outgoing,
      status: CallStatus.completed,
    );
  }

  factory CallRecord.fromDialpad({
    required String number,
    required DateTime startedAt,
    String? name,
    CallStatus status = CallStatus.completed,
    int durationSeconds = 0,
  }) {
    final trimmedName = name?.trim();
    return CallRecord(
      name: trimmedName == null || trimmedName.isEmpty ? number : trimmedName,
      phone: number,
      startedAt: startedAt,
      direction: CallDirection.outgoing,
      status: status,
      durationSeconds: durationSeconds,
    );
  }

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    return CallRecord(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      direction: CallDirection.fromJson(json['direction'] as String?),
      status: CallStatus.fromJson(json['status'] as String?),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }

  final String name;
  final String phone;
  final DateTime startedAt;
  final CallDirection direction;
  final CallStatus status;
  final int durationSeconds;

  ContactPreview get contact {
    return ContactPreview.fromNameAndPhone(name: name, phone: phone);
  }

  String get relativeTime {
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed.inMinutes < 1) return 'Just now';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes}m ago';
    if (elapsed.inDays < 1) return '${elapsed.inHours}h ago';
    return '${elapsed.inDays}d ago';
  }

  String get metadata {
    final parts = [
      direction.label,
      status.label,
      if (durationSeconds > 0) _durationLabel,
    ];
    return parts.join(' • ');
  }

  String get durationLabel {
    if (durationSeconds <= 0) return '0s';
    return _durationLabel;
  }

  String get startedAtLabel {
    final local = startedAt.toLocal();
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.month}/${local.day}/${local.year} $hour:$minute $period';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'direction': direction.value,
      'status': status.value,
      'durationSeconds': durationSeconds,
    };
  }

  String get _durationLabel {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}

enum CallDirection {
  outgoing('outgoing', 'Outgoing'),
  incoming('incoming', 'Incoming'),
  missed('missed', 'Missed');

  const CallDirection(this.value, this.label);

  final String value;
  final String label;

  static CallDirection fromJson(String? value) {
    return CallDirection.values.firstWhere(
      (direction) => direction.value == value,
      orElse: () => CallDirection.outgoing,
    );
  }
}

enum CallStatus {
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  missed('missed', 'Missed'),
  failed('failed', 'Failed');

  const CallStatus(this.value, this.label);

  final String value;
  final String label;

  static CallStatus fromJson(String? value) {
    return CallStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CallStatus.completed,
    );
  }
}
