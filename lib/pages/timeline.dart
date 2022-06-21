import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/models/user.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/headerTitle.dart';
import 'package:carepetsapp/pages/post.dart';
import 'package:carepetsapp/widgets/progress.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  const Timeline({required this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  //Variables
  List<Post>? posts;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser!.id)
        .collection('userFollowing')
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList(); //document.id
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts!.isEmpty) {
      return const Text(
        "",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return ListView(children: posts!);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: headerTitle(context, titleText: "Publicaciones"),
        body: RefreshIndicator(
          onRefresh: () => getTimeline(),
          child: buildTimeline(),
        ));
  }
}
