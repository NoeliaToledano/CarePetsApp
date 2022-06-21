import 'package:carepetsapp/models/pet.dart';
import 'package:carepetsapp/pages/myPets.dart';
import 'package:carepetsapp/pages/myReminders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/headerBack.dart';
import 'package:carepetsapp/widgets/menu.dart';

class CareMyPets extends StatefulWidget {
  @override
  _CareMyPetsState createState() => _CareMyPetsState();
}

class _CareMyPetsState extends State<CareMyPets> {
  //Variables
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController? pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController!.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: headerBack(context, titleText: "Cuidada de tu mascota"),
      drawer: Drawer(child: construirListView(context, currentUser)),
      body: PageView(
        children: <Widget>[
          //MyPets(),
          MyReminders(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
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
              leading: Image.network(pet.mediaUrl),
              contentPadding: const EdgeInsets.all(20),
              title: Text(
                pet.name,
              ),
              subtitle: Text(
                "Sexo: " + pet.gender,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
