import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String userId;
  final String title;
  final String platform;
  final String url;
  final String? imageUrl;
  final String? creatorName;
  final String status;
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
      platform: data['platform'] ?? 'Kickstarter',
      url: data['url'] ?? '',
      imageUrl: data['imageUrl'] as String?,
      creatorName: data['creatorName'] as String?,
      status: data['status'] ?? 'Upcoming',
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
      'platform': platform,
      'url': url,
      'imageUrl': imageUrl,
      'creatorName': creatorName,
      'status': status,
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
