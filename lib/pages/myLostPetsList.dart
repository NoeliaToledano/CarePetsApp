import 'package:carepetsapp/models/lostPet.dart';
import 'package:carepetsapp/pages/addLostPet.dart';
import 'package:carepetsapp/pages/editLostPet.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/pages/lostPets.dart';
import 'package:carepetsapp/widgets/customImage.dart';
import 'package:carepetsapp/widgets/menu.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyLostPetsList extends StatefulWidget {
  @override
  _MyLostPetsListState createState() => _MyLostPetsListState();
}

class _MyLostPetsListState extends State<MyLostPetsList> {
  //Variables
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  @override
  void dispose() {
    super.dispose();
  }

  void initState() {
    super.initState();
  }

  buildPetsResults(userId) {
    Future<QuerySnapshot> pets =
        lostPetsRef.where("ownerId", isEqualTo: currentUser!.id).get();
    setState(() {
      searchResultsFuture = pets;
    });
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<MyLostPetResult> searchResults = [];
        for (var doc in snapshot.data!.docs) {
          LostPet lostPet = LostPet.fromDocument(doc);
          MyLostPetResult searchResult = MyLostPetResult(lostPet);
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
        drawer: Drawer(child: construirListView(context, currentUser)),
        body: buildPetsResults(currentUser!.id),
        floatingActionButton: SizedBox(
          height: 60.0,
          width: 60.0,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddLostPet())
                      ..completed.then(
                        (_) {
                          Navigator.pop(context);
                          Route ruta = MaterialPageRoute(
                              builder: (context) => LostPets());
                          Navigator.push(context, ruta).then((value) => null);
                        },
                      ));
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
        lostPetsRef.doc(currentUser!.id).collection('userPets').get();
    setState(() {
      searchResultsFuture = pets;
    });
  }
}

class MyLostPetResult extends StatelessWidget {
  final LostPet lostPet;
  const MyLostPetResult(this.lostPet);

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
                        builder: (context) => EditLostPet(
                              lostPetId: lostPet.id,
                            ))
                      ..completed.then(
                        (_) {
                          Navigator.pop(context);
                          Route ruta = MaterialPageRoute(
                              builder: (context) => LostPets());
                          Navigator.push(context, ruta).then((value) => null);
                        },
                      ));
              },
              leading: cachedNetworkImage(
                lostPet.mediaUrl,
              ),
              title: Text(
                lostPet.name,
              ),
              subtitle: Text(
                "Sexo: " + lostPet.gender + "  Edad: " + lostPet.age.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
