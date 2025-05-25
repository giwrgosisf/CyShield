class PairingRequest {
  final String id;
  final String childId;
  final String childName;
  final String parentId;
  final DateTime timestamp;
  final String status;

  PairingRequest({
    String? id,
    required this.childId,
    required this.childName,
    required this.parentId,
    required this.timestamp,
    this.status = 'pending',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'childName': childName,
      'parentId': parentId,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory PairingRequest.fromJson(Map<String, dynamic> json) {
    return PairingRequest(
      id: json['id'],
      childId: json['childId'],
      childName: json['childName'],
      parentId: json['parentId'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'pending',
    );
  }

  PairingRequest copyWith({
    String? id,
    String? childId,
    String? childName,
    String? parentId,
    DateTime? timestamp,
    String? status,
  }) {
    return PairingRequest(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      parentId: parentId ?? this.parentId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}