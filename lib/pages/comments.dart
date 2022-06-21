import 'package:cached_network_image/cached_network_image.dart';
import 'package:carepetsapp/pages/activity_feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carepetsapp/pages/home.dart';
import 'package:carepetsapp/widgets/headerBack.dart';
import 'package:carepetsapp/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  final String commentId;

  const Comments({
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
    required this.commentId,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: postId,
        postOwnerId: postOwnerId,
        postMediaUrl: postMediaUrl,
        commentId: commentId,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  final String commentId;

  CommentsState({
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
    required this.commentId,
  });

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
        stream: commentsRef
            .doc(postId)
            .collection('comments')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          snapshot.data!.docs.forEach((doc) {
            //revisar
            comments.add(Comment.fromDocument(doc));
          });
          return GestureDetector(
            child: ListView(
              children: comments,
            ),
            /*onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text("¿Deseas eliminar el comentario?"),
                      actions: <Widget>[
                        FlatButton(
                          child: const Text(
                            "No",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: const Text(
                            "Si",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () => deleteComment(),
                        ),
                      ],
                    );
                  })*/
          );
        });
  }

  deleteComment() {
    commentsRef
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  addComment() {
    String commentId = const Uuid().v4();

    commentsRef.doc(postId).collection("comments").doc(commentId).set({
      "username": currentUser!.username,
      "comment": commentController.text,
      "timestamp": DateTime.now(),
      "avatarUrl": currentUser!.photoUrl,
      "userId": currentUser!.id,
      "commentId": commentId,
    });
    bool isNotPostOwner = postOwnerId != currentUser!.id;
    if (isNotPostOwner) {
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": DateTime.now(),
        "postId": postId,
        "userId": currentUser!.id,
        "username": currentUser!.username,
        "userProfileImg": currentUser!.photoUrl,
        "mediaUrl": postMediaUrl,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerBack(context, titleText: "Comentarios"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration:
                  const InputDecoration(labelText: "Escribe un comentario..."),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: const Text("Enviar"),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final String commentId;
  final Timestamp timestamp;

  const Comment({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.commentId,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      commentId: doc['commentId'],
      avatarUrl: doc['avatarUrl'],
    );
  }

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
            onTap: () => showProfile(context, profileId: userId),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: CachedNetworkImageProvider(avatarUrl),
              ),
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: username + " ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: comment),
                  ],
                ),
              ),
              subtitle: Text(
                timeago.format(timestamp.toDate(), locale: 'es'),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
