import 'package:cached_network_image/cached_network_image.dart';
import 'package:carepetsapp/models/user.dart';
import 'package:carepetsapp/pages/activity_feed.dart';
import 'package:carepetsapp/widgets/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/progress.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;
  const FollowingScreen({required this.userId});

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  Future<QuerySnapshot>? searchResultsFuture;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  buildFollowingResults() {
    Future<QuerySnapshot> followers =
        followingRef.doc(widget.userId).collection('userFollowing').get();
    setState(() {
      searchResultsFuture = followers;
    });
    return FutureBuilder<QuerySnapshot>(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          List<FollowingScreenResult> searchResults = [];
          for (var doc in snapshot.data!.docs) {
            User user = User.fromDocument(doc);
            if (widget.userId != user.id) {
              FollowingScreenResult searchResult = FollowingScreenResult(user);
              searchResults.add(searchResult);
            }
          }

          return Center(
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  "Siguiendo",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Signatra",
                    fontSize: 50.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).accentColor,
              ),
              body: SingleChildScrollView(
                  child: Column(children: <Widget>[
                ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: searchResults,
                ),
              ])),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _pullRefresh(),
      child: Scaffold(
        drawer: Drawer(child: construirListView(context, currentUser)),
        body: buildFollowingResults(),
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

class FollowingScreenResult extends StatelessWidget {
  final User user;
  const FollowingScreenResult(this.user);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10, //height of button
          ),
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
