import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String description;
  final String type;
  final String ownerId;
  final String petId;
  final String id;
  final String petName;
  final String reminderType;
  final Timestamp date;

  Reminder({
    required this.description,
    required this.type,
    required this.ownerId,
    required this.petId,
    required this.id,
    required this.petName,
    required this.reminderType,
    required this.date,
  });

  factory Reminder.fromDocument(DocumentSnapshot doc) {
    return Reminder(
      description: doc['description'],
      type: doc['type'],
      ownerId: doc['ownerId'],
      petId: doc['petId'],
      id: doc['id'],
      petName: doc['petName'],
      reminderType: doc['reminderType'],
      date: doc['date'],
    );
  }
}
