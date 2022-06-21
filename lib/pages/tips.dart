import 'package:cached_network_image/cached_network_image.dart';
import 'package:carepetsapp/models/tip.dart';
import 'package:carepetsapp/widgets/headerBack.dart';
import 'package:carepetsapp/widgets/menu.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Tips extends StatefulWidget {
  @override
  _TipsState createState() => _TipsState();
}

class _TipsState extends State<Tips> {
  //Variables
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

  buildTipsResults() {
    Future<QuerySnapshot> tips = tipsRef.get();
    setState(() {
      searchResultsFuture = tips;
    });
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<TipResult> searchResults = [];
        for (var doc in snapshot.data!.docs) {
          Tip tip = Tip.fromDocument(doc);
          TipResult searchResult = TipResult(tip);
          searchResults.add(searchResult);
        }
        return Column(
          children: <Widget>[
            CarouselSlider(
              items: searchResults,
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 0.53,
                viewportFraction: 1.5,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 2000),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerBack(context, titleText: "Consejos"),
      drawer: Drawer(child: construirListView(context, currentUser)),
      body: buildTipsResults(),
    );
  }
}

class TipResult extends StatelessWidget {
  final Tip tip;
  const TipResult(this.tip);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 218, 240, 236),
      child: Column(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: tip.mediaUrl,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(150, 120, 150, 0),
            child: Text(
              tip.description,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Saudagar',
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
