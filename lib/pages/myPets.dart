import 'package:carepetsapp/models/pet.dart';
import 'package:carepetsapp/pages/addPet.dart';
import 'package:carepetsapp/pages/editPet.dart';
import 'package:carepetsapp/widgets/customImage.dart';
import 'package:carepetsapp/widgets/headerTitle.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/menu.dart';

class MyPets extends StatefulWidget {
  @override
  _MyPetsState createState() => _MyPetsState();
}

class _MyPetsState extends State<MyPets> {
  //Variables
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  buildPetsResults(userId) {
    Future<QuerySnapshot> pets =
        myPetsRef.where("ownerId", isEqualTo: currentUser!.id).get();
    setState(() {
      searchResultsFuture = pets;
    });
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<PetResult> searchResults = [];
        for (var doc in snapshot.data!.docs) {
          Pet pet = Pet.fromDocument(doc);
          PetResult searchResult = PetResult(pet);
          searchResults.add(searchResult);
        }
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(context) {
    return RefreshIndicator(
      onRefresh: () => _pullRefresh(),
      child: Scaffold(
        appBar: headerTitle(
          context,
          titleText: "Mis mascotas",
        ),
        drawer: Drawer(child: construirListView(context, currentUser)),
        body: buildPetsResults(currentUser!.id),
        floatingActionButton: SizedBox(
          height: 60.0,
          width: 60.0,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddPet()))
                    .then((_) => setState(() {}));
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    Future<QuerySnapshot> pets =
        myPetsRef.doc(currentUser!.id).collection('userPets').get();
    setState(() {
      searchResultsFuture = pets;
    });
  }
}

class PetResult extends StatelessWidget {
  final Pet pet;
  const PetResult(this.pet);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      color: const Color.fromARGB(255, 218, 240, 236),
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.all(20),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditPet(
                              petId: pet.id,
                            )));
                ;
              },
              leading: cachedNetworkImage(
                pet.mediaUrl,
              ),
              title: Text(
                pet.name,
              ),
              subtitle: Text(
                "Sexo: " + pet.gender + "  Edad: " + pet.age.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
