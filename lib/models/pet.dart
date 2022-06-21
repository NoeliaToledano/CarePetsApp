import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String name;
  final String mediaUrl;
  final String ownerId;
  final String gender;
  final String description;
  final String numberChip;
  final String type;
  final String id;
  final int age;
  final bool sterilized;
  final bool vaccinated;

  Pet({
    required this.name,
    required this.mediaUrl,
    required this.ownerId,
    required this.gender,
    required this.description,
    required this.numberChip,
    required this.type,
    required this.id,
    required this.age,
    required this.sterilized,
    required this.vaccinated,
  });

  factory Pet.fromDocument(DocumentSnapshot doc) {
    return Pet(
      name: doc['name'],
      mediaUrl: doc['mediaUrl'],
      ownerId: doc['ownerId'],
      gender: doc['gender'],
      description: doc['description'],
      numberChip: doc['numberChip'],
      type: doc['type'],
      id: doc['id'],
      age: doc['age'],
      sterilized: doc['sterilized'],
      vaccinated: doc['vaccinated'],
    );
  }
}
