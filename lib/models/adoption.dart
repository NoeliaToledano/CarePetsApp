import 'package:cloud_firestore/cloud_firestore.dart';

class Adoption {
  final String name;
  final String mediaUrl;
  final String ownerId;
  final String gender;
  final String email;
  final String petBreed;
  final String province;
  final String location;
  final String description;
  final String type;
  final String id;
  final int age;
  final int numberPhone;
  final bool sterilized;
  final bool vaccinated;
  final Timestamp timeStamp;

  Adoption({
    required this.name,
    required this.mediaUrl,
    required this.ownerId,
    required this.gender,
    required this.email,
    required this.petBreed,
    required this.province,
    required this.location,
    required this.description,
    required this.type,
    required this.id,
    required this.age,
    required this.numberPhone,
    required this.sterilized,
    required this.vaccinated,
    required this.timeStamp,
  });

  factory Adoption.fromDocument(DocumentSnapshot doc) {
    return Adoption(
      name: doc['name'],
      mediaUrl: doc['mediaUrl'],
      ownerId: doc['ownerId'],
      gender: doc['gender'],
      email: doc['email'],
      petBreed: doc['petBreed'],
      province: doc['province'],
      location: doc['location'],
      description: doc['description'],
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
