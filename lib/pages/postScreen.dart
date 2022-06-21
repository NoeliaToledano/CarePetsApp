import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/pages/post.dart';
import 'package:carepetsapp/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  const PostScreen({required this.userId, required this.postId});
  @override
  Widget build(BuildContext context) {
    //Variables
    return FutureBuilder(
      future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data as DocumentSnapshot);
        return Center(
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "Publicacion",
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
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
