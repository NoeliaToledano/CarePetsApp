import 'package:cloud_firestore/cloud_firestore.dart';

class Tip {
  final String description;
  final String mediaUrl;
  final String id;

  Tip({
    required this.description,
    required this.mediaUrl,
    required this.id,
  });

  factory Tip.fromDocument(DocumentSnapshot doc) {
    return Tip(
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      id: doc['id'],
    );
  }
}
