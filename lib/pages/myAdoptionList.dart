import 'package:carepetsapp/models/adoption.dart';
import 'package:carepetsapp/pages/addAdoption.dart';
import 'package:carepetsapp/pages/adoptions.dart';
import 'package:carepetsapp/pages/editAdoption.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/menu.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyAdoptionList extends StatefulWidget {
  @override
  _MyAdoptionListState createState() => _MyAdoptionListState();
}

class _MyAdoptionListState extends State<MyAdoptionList> {
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
        adoptionsRef.where("ownerId", isEqualTo: currentUser!.id).get();
    setState(() {
      searchResultsFuture = pets;
    });
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<MyAdoptionResult> searchResults = [];
        for (var doc in snapshot.data!.docs) {
          Adoption adoption = Adoption.fromDocument(doc);
          MyAdoptionResult searchResult = MyAdoptionResult(adoption);
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
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddAdoption())
                      ..completed.then(
                        (_) {
                          Navigator.pop(context);
                          Route ruta = MaterialPageRoute(
                              builder: (context) => Adoptions());
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

class MyAdoptionResult extends StatelessWidget {
  final Adoption adoption;
  const MyAdoptionResult(this.adoption);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 218, 240, 236),
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditAdoption(
                          adoptionId: adoption.id,
                        ))
                  ..completed.then(
                    (_) {
                      Navigator.pop(context);
                      Route ruta =
                          MaterialPageRoute(builder: (context) => Adoptions());
                      Navigator.push(context, ruta).then((value) => null);
                    },
                  ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Image.network(
                  adoption.mediaUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              ListTile(
                title: Text(adoption.name),
                subtitle: Text("Sexo: " + adoption.gender),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
