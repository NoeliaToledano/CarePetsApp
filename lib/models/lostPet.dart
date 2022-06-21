import 'package:cloud_firestore/cloud_firestore.dart';

class LostPet {
  final String name;
  final String mediaUrl;
  final String ownerId;
  final String gender;
  final String email;
  final String petBreed;
  final String province;
  final String location;
  final String description;
  final String numberChip;
  final String type;
  final String id;
  final int age;
  final int numberPhone;
  final bool sterilized;
  final bool vaccinated;
  final Timestamp timeStamp;

  LostPet({
    required this.name,
    required this.mediaUrl,
    required this.ownerId,
    required this.gender,
    required this.email,
    required this.petBreed,
    required this.province,
    required this.location,
    required this.description,
    required this.numberChip,
    required this.type,
    required this.id,
    required this.age,
    required this.numberPhone,
    required this.sterilized,
    required this.vaccinated,
    required this.timeStamp,
  });

  factory LostPet.fromDocument(DocumentSnapshot doc) {
    return LostPet(
      name: doc['name'],
      mediaUrl: doc['mediaUrl'],
      ownerId: doc['ownerId'],
      gender: doc['gender'],
      email: doc['email'],
      petBreed: doc['petBreed'],
      province: doc['province'],
      location: doc['location'],
      description: doc['description'],
      numberChip: doc['numberChip'],
      type: doc['type'],
      id: doc['id'],
      age: doc['age'],
      numberPhone: doc['numberPhone'],
      sterilized: doc['sterilized'],
      vaccinated: doc['vaccinated'],
      timeStamp: doc['timeStamp'],
    );
  }
}
