import 'package:cached_network_image/cached_network_image.dart';
import 'package:carepetsapp/models/user.dart';
import 'package:carepetsapp/pages/activity_feed.dart';
import 'package:carepetsapp/pages/post.dart';
import 'package:carepetsapp/widgets/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/progress.dart';

class LikesScreen extends StatefulWidget {
  final String userId, postId;
  const LikesScreen({required this.userId, required this.postId});

  @override
  _LikesScreenState createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  Future<QuerySnapshot>? searchResultsFuture;
  List<User> users = [];
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  getUsers() async {
    QuerySnapshot snapshot = await usersRef.get();

    for (var doc in snapshot.docs) {
      User user = User.fromDocument(doc);
      users.add(user);
    }
  }

  buildFollowingResults() {
    Future<QuerySnapshot> posts =
        postsRef.doc(widget.userId).collection('userPosts').get();
    setState(() {
      searchResultsFuture = posts;
    });
    return FutureBuilder<QuerySnapshot>(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          List<LikesScreenResult> searchResults = [];
          for (var doc in snapshot.data!.docs) {
            Post post = Post.fromDocument(doc);
            if (post.postId == widget.postId) {
              dynamic likes = post.likes;
              likes.forEach((key, value) {
                String userId = key;
                for (var i = 0; i < users.length; i++) {
                  if (userId == users[i].id) {
                    LikesScreenResult searchResult =
                        LikesScreenResult(users[i]);
                    searchResults.add(searchResult);
                  }
                }
              });
            }
          }

          return Center(
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  "Me gusta",
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

class LikesScreenResult extends StatelessWidget {
  final User user;
  const LikesScreenResult(this.user);

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
