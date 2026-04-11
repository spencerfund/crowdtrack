import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectPlatform {
  kickstarter,
  backerkit,
  gamefound,
  other;

  String get displayName {
    switch (this) {
      case ProjectPlatform.kickstarter: return 'Kickstarter';
      case ProjectPlatform.backerkit: return 'Backerkit';
      case ProjectPlatform.gamefound: return 'Gamefound';
      case ProjectPlatform.other: return 'Other';
    }
  }

  static ProjectPlatform fromString(String value) {
    return ProjectPlatform.values.firstWhere(
      (e) => e.displayName == value || e.name == value,
      orElse: () => ProjectPlatform.other,
    );
  }
}

enum ProjectStatus {
  upcoming,
  interested,
  funding,
  funded,
  pledged,
  shipped,
  delivered;

  String get displayName {
    switch (this) {
      case ProjectStatus.upcoming: return 'Upcoming';
      case ProjectStatus.interested: return 'Interested';
      case ProjectStatus.funding: return 'Funding';
      case ProjectStatus.funded: return 'Funded';
      case ProjectStatus.pledged: return 'Pledged';
      case ProjectStatus.shipped: return 'Shipped';
      case ProjectStatus.delivered: return 'Delivered';
    }
  }

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (e) => e.displayName == value || e.name == value,
      orElse: () => ProjectStatus.upcoming,
    );
  }
}

class Project {
  final String id;
  final String userId;
  final String title;
  final ProjectPlatform platform;
  final String url;
  final String? imageUrl;
  final String? creatorName;
  final ProjectStatus status;
  final bool backed;
  final double? pledgeAmount;
  final String? currency;
  final String? estimatedDelivery;
  final String? trackingLink;
  final String? campaignBeginDate;
  final String? campaignEndDate;
  final Timestamp? lastUpdate;
  final String? notes;
  final Timestamp? createdAt;

  Project({
    required this.id,
    required this.userId,
    required this.title,
    required this.platform,
    required this.url,
    this.imageUrl,
    this.creatorName,
    required this.status,
    required this.backed,
    this.pledgeAmount,
    this.currency,
    this.estimatedDelivery,
    this.trackingLink,
    this.campaignBeginDate,
    this.campaignEndDate,
    this.lastUpdate,
    this.notes,
    this.createdAt,
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data was null');
    }
    
    // Helper to safely parse numbers
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      if (val is String) return double.tryParse(val);
      return null;
    }

    return Project(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      platform: ProjectPlatform.fromString(data['platform'] ?? 'Kickstarter'),
      url: data['url'] ?? '',
      imageUrl: data['imageUrl'] as String?,
      creatorName: data['creatorName'] as String?,
      status: ProjectStatus.fromString(data['status'] ?? 'Upcoming'),
      backed: data['backed'] ?? false,
      pledgeAmount: parseDouble(data['pledgeAmount']),
      currency: data['currency'] as String?,
      estimatedDelivery: data['estimatedDelivery'] as String?,
      trackingLink: data['trackingLink'] as String?,
      campaignBeginDate: data['campaignBeginDate'] as String?,
      campaignEndDate: data['campaignEndDate'] as String?,
      lastUpdate: data['lastUpdate'] as Timestamp?,
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'platform': platform.displayName,
      'url': url,
      'imageUrl': imageUrl,
      'creatorName': creatorName,
      'status': status.displayName,
      'backed': backed,
      'pledgeAmount': pledgeAmount,
      'currency': currency,
      'estimatedDelivery': estimatedDelivery,
      'trackingLink': trackingLink,
      'campaignBeginDate': campaignBeginDate,
      'campaignEndDate': campaignEndDate,
      'lastUpdate': lastUpdate ?? FieldValue.serverTimestamp(),
      'notes': notes,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
