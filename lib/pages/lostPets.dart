import 'package:carepetsapp/pages/lostPetsList.dart';
import 'package:carepetsapp/pages/myLostPetsList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/menu.dart';

class LostPets extends StatefulWidget {
  @override
  _LostPetsState createState() => _LostPetsState();
}

class _LostPetsState extends State<LostPets>
    with SingleTickerProviderStateMixin {
  //Variables
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  late TabController _controllerTabs;

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Animales perdidos'),
    Tab(text: 'Mis animales perdidos'),
  ];

  static final List<Widget> _views = [
    LostPetsList(),
    MyLostPetsList(),
  ];

  @override
  void initState() {
    super.initState();
    _controllerTabs = TabController(vsync: this, initialIndex: 0, length: 2);
  }

  @override
  void dispose() {
    _controllerTabs.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return RefreshIndicator(
      onRefresh: () => _pullRefresh(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text(
            "Animales perdidos",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Signatra",
              fontSize: 40.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            controller: _controllerTabs,
            tabs: myTabs,
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).accentColor,
        ),
        drawer: Drawer(child: construirListView(context, currentUser)),
        body: TabBarView(controller: _controllerTabs, children: _views),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    Future<QuerySnapshot> pets =
        lostPetsRef.doc(currentUser!.id).collection('adoptionsPets').get();
    setState(() {
      searchResultsFuture = pets;
    });
  }
}
